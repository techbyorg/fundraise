{z, useMemo, useStream} = require 'zorium'
_find = require 'lodash/find'
RxBehaviorSubject = require('rxjs/BehaviorSubject').BehaviorSubject

$button = require '../button'
$filterBar = require '../filter_bar'
# $irsSearch = require '../irs_search'
$fundSearchResults = require '../fund_search_results'
$input = require '../input'
$searchTags = require '../search_tags'
$table = require '../table'
FormatService = require '../../services/format'
SearchFiltersService = require '../../services/search_filters'

if window?
  require './index.styl'

module.exports = $search = ({model, router, org}) ->
  {filtersStream, modeStream, searchResultsStream} = useMemo ->
    filtersStream = SearchFiltersService.getFiltersStream {
      model, filters: SearchFiltersService.getFundFilters(model)
    }

    esQueryFilterStream = filtersStream.map (filters) ->
      SearchFiltersService.getESQueryFilterFromFilters(
        filters
      )

    {
      filtersStream
      modeStream: new RxBehaviorSubject 'tags'
      searchResultsStream: esQueryFilterStream.switchMap (esQueryFilter) ->
        console.log 'es', esQueryFilter
        model.irsFund.search {
          query:
            bool:
              filter: esQueryFilter
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
      z '.search-box',
        if mode is 'specific'
          z $input,
            hintText: model.l.get 'fundSearch.byNameEinPlaceholder'
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
