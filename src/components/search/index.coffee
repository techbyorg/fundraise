{z, useMemo, useStream} = require 'zorium'

$filterBar = require '../filter_bar'
$irsSearch = require '../irs_search'
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
        console.log 'query', esQueryFilter
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

  console.log 'RESSSS', searchResults

  z '.z-search',
    z '.search-box',
      # TODO: own component?
      z '.search-tags-input'
    z $filterBar, {model, filtersStream}

    z '.results',
      z $table,
        data: searchResults?.nodes
        columns: [
          {key: 'name', name: 'Name', width: 240, isFlex: true}
          {
            key: 'assets', name: 'Assets'
            content: ({row}) ->
              FormatService.number row.assets
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
