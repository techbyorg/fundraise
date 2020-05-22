{z, useMemo, useStream} = require 'zorium'

$filterBar = require '../filter_bar'
$irsSearch = require '../irs_search'
$searchTags = require '../search_tags'
$table = require '../table'
FormatService = require '../../services/format'
SearchFiltersService = require '../../services/search_filters'

if window?
  require './index.styl'

module.exports = OrgBox = ({model, router, org}) ->
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
        model.irsFund.search {
          query:
            bool:
              filter: esQueryFilter
          limit: 10
        }
    }
  , []

  {searchResults} = useStream ->
    searchResults: searchResultsStream

  z '.z-search',
    z '.search',
      z '.search-box',
        z $searchTags,
          title: model.l.get 'fund.focusAreas'
        z $searchTags,
          title: model.l.get 'general.location'

    z '.results',
      z '.title',
        model.l.get 'fundSearch.resultsTitle', {
          replacements:
            count: FormatService.number searchResults?.totalCount
        }
      z '.filter-bar',
        z $filterBar, {model, filtersStream}
      z $table,
        data: searchResults?.nodes
        onRowClick: (e, i) ->
          router.goFund searchResults.nodes[i]
        columns: [
          {key: 'name', name: 'Name', width: 240, isFlex: true}
          {
            key: 'assets', name: model.l.get('org.assets')
            width: 150
            content: ({row}) ->
              FormatService.abbreviateDollar row.assets
          }
          {
            key: 'grantMedian', name: model.l.get('fund.medianGrant')
            width: 170
            content: ({row}) ->
              FormatService.abbreviateDollar row.lastYearStats?.grantMedian
          }
          {
            key: 'grantSum', name: model.l.get('fund.grantsPerYear')
            width: 150
            content: ({row}) ->
              FormatService.abbreviateDollar row.lastYearStats?.grantSum
          }
        ]


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
