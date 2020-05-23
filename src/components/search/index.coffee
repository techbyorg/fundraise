{z, useMemo, useStream} = require 'zorium'
_find = require 'lodash/find'

$filterBar = require '../filter_bar'
$irsSearch = require '../irs_search'
$fundSearchResults = require '../fund_search_results'
$searchTags = require '../search_tags'
$table = require '../table'
FormatService = require '../../services/format'
SearchFiltersService = require '../../services/search_filters'

if window?
  require './index.styl'

module.exports = $search = ({model, router, org}) ->
  {searchResultsStream, filtersStream} = useMemo ->
    filtersStream = SearchFiltersService.getFiltersStream {
      model, filters: SearchFiltersService.getFundFilters(model)
    }

    esQueryFilterStream = filtersStream.map (filters) ->
      SearchFiltersService.getESQueryFilterFromFilters(
        filters
      )

    {
      filtersStream
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

  {focusAreasFilter, searchResults} = useStream ->
    focusAreasFilter: filtersStream.map (filters) ->
      _find filters, {id: 'fundedNteeMajor'}
    searchResults: searchResultsStream

  console.log searchResults

  z '.z-search',
    z '.search',
      z '.search-box',
        z $searchTags,
          model: model
          filter: focusAreasFilter
          title: model.l.get 'fund.focusAreas'
          placeholder: model.l.get 'fundSearch.focusAreasPlaceholder'
        # z $searchTags,
        #   title: model.l.get 'general.location'
        #   placeholder: model.l.get 'fundSearch.locationPlaceholder'

    z '.results',
      z '.title',
        model.l.get 'fundSearch.resultsTitle', {
          replacements:
            count: FormatService.number searchResults?.totalCount
        }
      z '.filter-bar',
        z $filterBar, {model, filtersStream}

      z $fundSearchResults, {model, router, rows: searchResults?.nodes}


    z '.title', 'Search foundations'
    z '.input',
      z $irsSearch, {
        model, router, irsType: 'irsFund', hintText: 'Foundation name'
      }
    z '.title', 'Search organizations'
    z '.input',
      z $irsSearch, {
        model, router, irsType: 'irsOrg', hintText: 'Organization name'
      }
    z '.title', 'Search people'
    z '.input',
      z $irsSearch, {
        model, router, irsType: 'irsPerson', hintText: 'Person name'
      }
