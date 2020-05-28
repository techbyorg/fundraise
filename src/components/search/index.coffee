{z, useContext, useMemo, useStream} = require 'zorium'
_find = require 'lodash/find'
RxBehaviorSubject = require('rxjs/BehaviorSubject').BehaviorSubject
RxObservable = require('rxjs/Observable').Observable
require 'rxjs/add/observable/combineLatest'
require 'rxjs/add/observable/of'

$button = require 'frontend-shared/components/button'
$input = require 'frontend-shared/components/input'
$table = require 'frontend-shared/components/table'
FormatService = require 'frontend-shared/services/format'

# $irsSearch = require '../irs_search'
$filterBar = require '../filter_bar'
$fundSearchResults = require '../fund_search_results'
$searchInput = require '../search_input'
$searchTags = require '../search_tags'
SearchFiltersService = require '../../services/search_filters'
context = require '../../context'

if window?
  require './index.styl'

module.exports = $search = ({org}) ->
  {model, lang, cookie} = useContext context

  {filtersStream, nameStream, modeStream, searchResultsStream} = useMemo ->
    filtersStream = SearchFiltersService.getFiltersStream {
      cookie, filters: SearchFiltersService.getFundFilters(lang)
    }
    nameStream = new RxBehaviorSubject ''

    esQueryFilterStream = filtersStream.map (filters) ->
      SearchFiltersService.getESQueryFilterFromFilters(
        filters
      )

    esQueryFilterAndNameStream = RxObservable.combineLatest(
      esQueryFilterStream, nameStream, (vals...) -> vals
    )

    {
      filtersStream
      nameStream
      modeStream: new RxBehaviorSubject 'tags'
      searchResultsStream: esQueryFilterAndNameStream
      .switchMap ([esQueryFilter, name]) ->
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

          limit: 10
        }
    }
  , []

  {mode, focusAreasFilter, statesFilter, searchResults} = useStream ->
    mode: modeStream
    focusAreasFilter: filtersStream.map (filters) ->
      _find filters, {id: 'fundedNteeMajor'}
    statesFilter: filtersStream.map (filters) ->
      _find filters, {id: 'state'}
    searchResults: searchResultsStream

  console.log searchResults

  z '.z-search',
    z '.search',
      z '.title', lang.get 'fundSearch.titleSpecific'
      z '.search-box',
        if mode is 'specific'
          z $searchInput,
            valueStream: nameStream
            placeholder: lang.get 'fundSearch.byNameEinPlaceholder'
        else
          [
            z $searchTags,
              filter: focusAreasFilter
              title: lang.get 'fund.focusAreas'
              placeholder: lang.get 'fundSearch.focusAreasPlaceholder'
            z '.divider'
            z $searchTags,
              filter: statesFilter
              title: lang.get 'general.location'
              placeholder: lang.get 'fundSearch.locationPlaceholder'
            z '.button',
              z $button,
                isPrimary: true
                icon: 'search'
                text: lang.get 'general.search'
          ]

      z '.alt', {
        onclick: ->
          if mode is 'specific'
            modeStream.next 'tags'
          else
            focusAreasFilter.valueStreams.next RxObservable.of null
            statesFilter.valueStreams.next RxObservable.of null
            modeStream.next 'specific'
      },
        z '.or', lang.get 'general.or'
        z '.text', lang.get 'fundSearch.byNameEin'

    z '.results',
      z '.title',
        lang.get 'fundSearch.resultsTitle', {
          replacements:
            count: FormatService.number searchResults?.totalCount
        }
      z '.filter-bar',
        z $filterBar, {filtersStream}

      z $fundSearchResults, {rows: searchResults?.nodes}


    # z '.title', 'Search foundations'
    # z '.input',
    #   z $irsSearch, {
    #     model, router, irsType: 'irsFund', hintText: 'Foundation name'
    #   }
    # z '.title', 'Search organizations'
    # z '.input',
    #   z $irsSearch, {
    #     model, router, irsType: 'irsOrg', hintText: 'Organization name'
    #   }
    # z '.title', 'Search people'
    # z '.input',
    #   z $irsSearch, {
    #     model, router, irsType: 'irsPerson', hintText: 'Person name'
    #   }
