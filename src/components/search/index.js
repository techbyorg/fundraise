// TODO: This file was created by bulk-decaffeinate.
// Sanity-check the conversion and remove this comment.
let $search;
import {z, classKebab, useContext, useMemo, useStream} from 'zorium';
import * as _ from 'lodash-es';
import * as Rx from 'rxjs';
import * as rx from 'rxjs/operators';

import $button from 'frontend-shared/components/button';
import $table from 'frontend-shared/components/table';
import $spinner from 'frontend-shared/components/spinner';
import {searchIconPath} from 'frontend-shared/components/icon/paths';
import FormatService from 'frontend-shared/services/format';

import $filterBar from '../filter_bar';
import $fundSearchResults from '../fund_search_results';
import $searchInput from '../search_input';
import $searchTags from '../search_tags';
import SearchFiltersService from '../../services/search_filters';
import context from '../../context';

if (typeof window !== 'undefined' && window !== null) {
  require('./index.styl');
}

export default $search = function({nteeStream, locationStream}) {
  const {model, lang, browser, cookie} = useContext(context);

  var {filtersStream, hasSearchedStream, hasHitSearchStream, isLoadingStream,
    nameStream, modeStream, searchResultsStream} = useMemo(function() {

    const initialFiltersStream = Rx.combineLatest(
      nteeStream, locationStream,
      function(ntee, location) {
        const filters = {};
        if (ntee) {
          filters['irsFund.fundedNteeMajor'] =
            {nteeMajors: {}, ntees: {[ntee.toUpperCase()]: true}};
        }
        if (location) {
          filters['irsFund.state'] = {[location.toUpperCase()]: true};
        }
        return filters;
    });

    filtersStream = SearchFiltersService.getFiltersStream({
      cookie,
      initialFiltersStream,
      filters: SearchFiltersService.getFundFilters(lang)
    });
    nameStream = new Rx.BehaviorSubject('');

    const esQueryFilterStream = filtersStream.pipe(rx.map(filters => SearchFiltersService.getESQueryFilterFromFilters(
      filters
    ))
    );

    const esQueryFilterAndNameStream = Rx.combineLatest(
      esQueryFilterStream, nameStream, (...vals) => vals);

    hasHitSearchStream = new Rx.BehaviorSubject(false);
    isLoadingStream = new Rx.BehaviorSubject(false);

    return {
      filtersStream,
      nameStream,
      hasHitSearchStream,
      isLoadingStream,
      hasSearchedStream: Rx.combineLatest(
        esQueryFilterStream, nameStream, hasHitSearchStream, (...vals) => vals).pipe(rx.map(function(...args) {
        const [esQueryFilter, name, hasHitSearch] = Array.from(args[0]);
        const hasSearchedBefore = cookie.get('hasSearched');
        const hasFilters = !_.isEmpty(esQueryFilter) || name;
        return (hasSearchedBefore && hasFilters) || hasHitSearch;
      })
      ),
      modeStream: new Rx.BehaviorSubject('tags'),
      searchResultsStream: esQueryFilterAndNameStream
      .pipe(
        rx.tap(() => isLoadingStream.next(true)),
        rx.switchMap(function(...args) {
          const [esQueryFilter, name] = Array.from(args[0]);
          const bool = {filter: esQueryFilter};
          if (name) {
            bool.must = {
              multi_match: {
                query: name,
                type: 'bool_prefix',
                fields: ['name', 'name._2gram', 'ein']
              }
            };
          }

          return model.irsFund.search({
            query: {
              bool
            },
            sort: [
              {'lastYearStats.grants': {order: 'desc'}}
            ],
            limit: 100
          });}),
        rx.tap(() => isLoadingStream.next(false))
      )
    };
  }
  , []);

  const {mode, hasSearched, isLoading, focusAreasFilter, statesFilter,
    searchResults, breakpoint} = useStream(() => ({
    mode: modeStream,
    hasSearched: hasSearchedStream,
    isLoading: isLoadingStream,
    focusAreasFilter: filtersStream.pipe(rx.map(filters => _.find(filters, {id: 'fundedNteeMajor'}))),
    statesFilter: filtersStream.pipe(rx.map(filters => _.find(filters, {id: 'state'}))),
    searchResults: searchResultsStream,
    breakpoint: browser.getBreakpoint()
  }));

  return z('.z-search', {
      className: classKebab({hasSearched})
  },
    z('.search',
      z('.title',
        mode === 'specific' ?
          z('.text', lang.get('fundSearch.titleSpecific'))
        :
          z('.text', lang.get('fundSearch.titleFocusArea'))
      ),
      z(`form.search-box.${mode}`, {
        onsubmit(e) {
          e.preventDefault();
          cookie.set('hasSearched', true);
          return hasHitSearchStream.next(true);
        }
      }, [
        mode === 'specific' ?
          z($searchInput, {
            valueStream: nameStream,
            placeholder: lang.get('fundSearch.byNameEinPlaceholder')
          }
          )
        :
          [
            z('.search-tags',
              z($searchTags, {
                filter: focusAreasFilter,
                title: lang.get('fund.focusAreas'),
                placeholder: lang.get('fundSearch.focusAreasPlaceholder')
              }
              )
            ),
            z('.divider'),
            z('.search-tags',
              z($searchTags, {
                filter: statesFilter,
                title: lang.get('general.location'),
                placeholder: lang.get('fundSearch.locationPlaceholder')
              }
              )
            )
          ],

        z('.button',
          z($button, {
            type: 'submit',
            isPrimary: breakpoint !== 'mobile',
            icon: searchIconPath,
            text: lang.get('general.search')
          }
          )
        )
        ]),


      z('.alt', {
        onclick() {
          if (mode === 'specific') {
            return modeStream.next('tags');
          } else {
            focusAreasFilter.valueStreams.next(Rx.of(null));
            statesFilter.valueStreams.next(Rx.of(null));
            return modeStream.next('specific');
          }
        }
      },
        z('.or', lang.get('general.or')),
        mode === 'specific' ?
          z('.text', lang.get('fundSearch.byFocusArea'))
        :
          z('.text', lang.get('fundSearch.byNameEin'))
      )
    ),

    hasSearched ?
      z('.results',
        z('.container',
          z('.title',
            lang.get('fundSearch.resultsTitle', {
              replacements: {
                count: FormatService.number(searchResults?.totalCount)
              }
            }),
            z('.loading', {
              className: classKebab({isLoading: searchResults && isLoading})
            },
              z($spinner, {size: 30}))),
          z('.filter-bar',
            z($filterBar, {filtersStream})),

          z($fundSearchResults, {rows: searchResults?.nodes}))) : undefined);
};
