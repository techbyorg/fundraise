import { z, classKebab, useContext, useMemo, useStream } from 'zorium'
import * as _ from 'lodash-es'
import * as Rx from 'rxjs'
import * as rx from 'rxjs/operators'

import $spinner from 'frontend-shared/components/spinner'
import FormatService from 'frontend-shared/services/format'

import $filterBar from '../filter_bar'
import $nonprofitSearchResults from '../nonprofit_search_results'
import $fundSearchResults from '../fund_search_results'
import $entitySearchBox from '../entity_search_box'
import SearchFiltersService from '../../services/search_filters'
import context from '../../context'

if (typeof window !== 'undefined' && window !== null) {
  require('./index.styl')
}

export default function $entitySearch (props) {
  const { nteeStream, locationStream, entityType } = props
  const { model, lang, cookie } = useContext(context)

  const {
    filtersStream, hasSearchedStream, hasHitSearchStream, isLoadingStream,
    nameStream, searchResultsStream
  } = useMemo(function () {
    const initialFiltersStream = Rx.combineLatest(
      nteeStream, locationStream,
      function (ntee, location) {
        const filters = {}
        if (ntee) {
          filters[`${entityType}.fundedNteeMajor`] =
            { nteeMajors: {}, ntees: { [ntee.toUpperCase()]: true } }
        }
        if (location) {
          filters[`${entityType}.state`] = { [location.toUpperCase()]: true }
        }
        return filters
      })

    const filtersStream = SearchFiltersService.getFiltersStream({
      cookie,
      initialFiltersStream,
      persistentCookie: `${entityType}Filters`,
      filters: entityType === 'irsNonprofit'
        ? SearchFiltersService.getNonprofitFilters(lang)
        : SearchFiltersService.getFundFilters(lang)
    })
    const nameStream = new Rx.BehaviorSubject('')

    const esQueryFilterStream = filtersStream.pipe(rx.map(filters =>
      SearchFiltersService.getESQueryFilterFromFilters(filters)
    ))

    const esQueryFilterAndNameStream = Rx.combineLatest(
      esQueryFilterStream, nameStream, (...vals) => vals)

    const hasHitSearchStream = new Rx.BehaviorSubject(false)
    const isLoadingStream = new Rx.BehaviorSubject(false)

    return {
      filtersStream,
      nameStream,
      hasHitSearchStream,
      isLoadingStream,
      hasSearchedStream: Rx.combineLatest(
        esQueryFilterStream, nameStream, hasHitSearchStream,
        (...vals) => vals
      ).pipe(rx.map(function ([esQueryFilter, name, hasHitSearch]) {
        const hasSearchedBefore = cookie.get('hasSearched')
        const hasFilters = !_.isEmpty(esQueryFilter) || name
        return (hasSearchedBefore && hasFilters) || hasHitSearch
      })),
      searchResultsStream: esQueryFilterAndNameStream
        .pipe(
          rx.tap(() => isLoadingStream.next(true)),
          rx.switchMap(function ([esQueryFilter, name]) {
            const bool = { filter: esQueryFilter }
            if (name) {
              if (model.irsNonprofit.isEin(name)) {
                name = name.replace('-', '')
              }
              bool.must = {
                multi_match: {
                  query: name,
                  type: 'bool_prefix',
                  fields: ['name', 'name._2gram', 'ein']
                }
              }
            }

            return model[entityType].search({
              query: { bool },
              sort: entityType === 'irsNonprofit'
                ? [{ volunteerCount: { order: 'desc' } }]
                : [{ 'lastYearStats.grants': { order: 'desc' } }],
              limit: 100
            })
          }),
          rx.tap(() => isLoadingStream.next(false))
        )
    }
  }, [])

  const {
    hasSearched, isLoading, searchResults
  } = useStream(() => ({
    hasSearched: hasSearchedStream,
    isLoading: isLoadingStream,
    searchResults: searchResultsStream
  }))

  const $searchResults = entityType === 'irsNonprofit'
    ? $nonprofitSearchResults
    : $fundSearchResults

  return z('.z-entity-search', {
    className: classKebab({ hasSearched })
  }, [
    z($entitySearchBox, {
      nameStream, filtersStream, hasHitSearchStream, hasSearched, entityType
    }),

    hasSearched &&
      z('.results', [
        z('.container', [
          z('.title', [
            lang.get(`${entityType}Search.resultsTitle`, {
              replacements: {
                count: FormatService.number(searchResults?.totalCount)
              }
            }),
            z('.loading', {
              className: classKebab({ isLoading: searchResults && isLoading })
            }, z($spinner, { size: 30 }))
          ]),
          z('.filter-bar', z($filterBar, { filtersStream })),
          z($searchResults, { rows: searchResults?.nodes })
        ])
      ])
  ])
};
