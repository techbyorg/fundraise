{z, useMemo, useStream} = require 'zorium'

$filterBar = require '../filter_bar'
$irsSearch = require '../irs_search'
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
        model.irsOrg.search {
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
    z $filterBar, {model, filtersStream}
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
