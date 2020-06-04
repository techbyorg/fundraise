import {z, classKebab, useContext, useMemo, useStream} from 'zorium'
import * as _ from 'lodash-es'
import * as Rx from 'rxjs'
import * as rx from 'rxjs/operators'

import $button from 'frontend-shared/components/button'
import $input from 'frontend-shared/components/input'
import $table from 'frontend-shared/components/table'
import {searchIconPath} from 'frontend-shared/components/icon/paths'
import FormatService from 'frontend-shared/services/format'

import $filterBar from '../filter_bar'
import $fundSearchResults from '../fund_search_results'
import $searchInput from '../search_input'
import $searchTags from '../search_tags'
import SearchFiltersService from '../../services/search_filters'
import context from '../../context'

if window?
  require './index.styl'

export default $search = ({org}) ->
  {model, lang, browser, cookie} = useContext context

  {filtersStream, hasSearchedStream, hasHitSearchStream, nameStream,
    modeStream, searchResultsStream} = useMemo ->
    filtersStream = SearchFiltersService.getFiltersStream {
      cookie, filters: SearchFiltersService.getFundFilters(lang)
    }
    nameStream = new Rx.BehaviorSubject ''

    esQueryFilterStream = filtersStream.pipe rx.map (filters) ->
      SearchFiltersService.getESQueryFilterFromFilters(
        filters
      )

    esQueryFilterAndNameStream = Rx.combineLatest(
      esQueryFilterStream, nameStream, (vals...) -> vals
    )

    hasHitSearchStream = new Rx.BehaviorSubject false

    {
      filtersStream
      nameStream
      hasHitSearchStream
      hasSearchedStream: Rx.combineLatest(
        esQueryFilterStream, nameStream, hasHitSearchStream, (vals...) -> vals
      ).pipe rx.map ([esQueryFilter, name, hasHitSearch]) ->
        hasSearchedBefore = cookie.get 'hasSearched'
        hasFilters = not _.isEmpty(esQueryFilter) or name
        (hasSearchedBefore and hasFilters) or hasHitSearch
      modeStream: new Rx.BehaviorSubject 'tags'
      searchResultsStream: esQueryFilterAndNameStream
      .pipe rx.switchMap ([esQueryFilter, name]) ->
        bool = {filter: esQueryFilter}
        if name
          bool.must =
            multi_match:
              query: name
              type: 'bool_prefix'
              fields: ['name', 'name._2gram', 'ein']

        model.irsFund.search {
          query:
            bool: bool

          limit: 100
        }
    }
  , []

  {mode, hasSearched, focusAreasFilter, statesFilter,
    searchResults, breakpoint} = useStream ->
    mode: modeStream
    hasSearched: hasSearchedStream
    focusAreasFilter: filtersStream.pipe rx.map (filters) ->
      _.find filters, {id: 'fundedNteeMajor'}
    statesFilter: filtersStream.pipe rx.map (filters) ->
      _.find filters, {id: 'state'}
    searchResults: searchResultsStream
    breakpoint: browser.getBreakpoint()

  z '.z-search', {
      className: classKebab {hasSearched}
  },
    z '.search',
      z '.title',
        if mode is 'specific'
          z '.text', lang.get 'fundSearch.titleSpecific'
        else
          z '.text', lang.get 'fundSearch.titleFocusArea'
      z "form.search-box.#{mode}", {
        onsubmit: (e) ->
          e.preventDefault()
          cookie.set 'hasSearched', true
          hasHitSearchStream.next true
      }, [
        if mode is 'specific'
          z $searchInput,
            valueStream: nameStream
            placeholder: lang.get 'fundSearch.byNameEinPlaceholder'
        else
          [
            z '.search-tags',
              z $searchTags,
                filter: focusAreasFilter
                title: lang.get 'fund.focusAreas'
                placeholder: lang.get 'fundSearch.focusAreasPlaceholder'
            z '.divider'
            z '.search-tags',
              z $searchTags,
                filter: statesFilter
                title: lang.get 'general.location'
                placeholder: lang.get 'fundSearch.locationPlaceholder'
          ]

        z '.button',
          z $button,
            type: 'submit'
            isPrimary: breakpoint isnt 'mobile'
            icon: searchIconPath
            text: lang.get 'general.search'
        ]


      z '.alt', {
        onclick: ->
          if mode is 'specific'
            modeStream.next 'tags'
          else
            focusAreasFilter.valueStreams.next Rx.of null
            statesFilter.valueStreams.next Rx.of null
            modeStream.next 'specific'
      },
        z '.or', lang.get 'general.or'
        if mode is 'specific'
          z '.text', lang.get 'fundSearch.byFocusArea'
        else
          z '.text', lang.get 'fundSearch.byNameEin'

    if hasSearched
      z '.results',
        z '.container',
          z '.title',
            lang.get 'fundSearch.resultsTitle', {
              replacements:
                count: FormatService.number searchResults?.totalCount
            }
          z '.filter-bar',
            z $filterBar, {filtersStream}

          z $fundSearchResults, {rows: searchResults?.nodes}
