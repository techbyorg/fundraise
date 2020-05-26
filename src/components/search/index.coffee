{z, useMemo, useStream} = require 'zorium'
_find = require 'lodash/find'
RxBehaviorSubject = require('rxjs/BehaviorSubject').BehaviorSubject
RxObservable = require('rxjs/Observable').Observable
require 'rxjs/add/observable/combineLatest'
require 'rxjs/add/observable/of'

$button = require '../button'
$filterBar = require '../filter_bar'
# $irsSearch = require '../irs_search'
$fundSearchResults = require '../fund_search_results'
$input = require '../input'
$searchInput = require '../search_input'
$searchTags = require '../search_tags'
$table = require '../table'
FormatService = require '../../services/format'
SearchFiltersService = require '../../services/search_filters'

if window?
  require './index.styl'

module.exports = $search = ({model, router, org}) ->
  {filtersStream, nameStream, modeStream, searchResultsStream} = useMemo ->
    filtersStream = SearchFiltersService.getFiltersStream {
      model, filters: SearchFiltersService.getFundFilters(model)
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
      z '.title', model.l.get 'fundSearch.titleSpecific'
      z '.search-box',
        if mode is 'specific'
          z $searchInput,
            valueStream: nameStream
            placeholder: model.l.get 'fundSearch.byNameEinPlaceholder'
        else
          [
            z $searchTags,
              model: model
              filter: focusAreasFilter
              title: model.l.get 'fund.focusAreas'
              placeholder: model.l.get 'fundSearch.focusAreasPlaceholder'
            z '.divider'
            z $searchTags,
              model: model
              filter: statesFilter
              title: model.l.get 'general.location'
              placeholder: model.l.get 'fundSearch.locationPlaceholder'
            z '.button',
              z $button,
                isPrimary: true
                icon: 'search'
                text: model.l.get 'general.search'
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
        z '.or', model.l.get 'general.or'
        z '.text', model.l.get 'fundSearch.byNameEin'

    z '.results',
      z '.title',
        model.l.get 'fundSearch.resultsTitle', {
          replacements:
            count: FormatService.number searchResults?.totalCount
        }
      z '.filter-bar',
        z $filterBar, {model, filtersStream}

      z $fundSearchResults, {model, router, rows: searchResults?.nodes}


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
