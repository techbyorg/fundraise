{z, useMemo, useStream} = require 'zorium'

$filterBar = require '../filter_bar'
$irsSearch = require '../irs_search'
SearchFiltersService = require '../../services/search_filters'

if window?
  require './index.styl'

module.exports = OrgBox = ({model, router, org}) ->
  {esQueryStream, filtersStream} = useMemo ->
    filtersStream = SearchFiltersService.getFiltersStream {
      model, filters: SearchFiltersService.getFundFilters()
    }

    {
      filtersStream
      esQueryStream: filtersStream.map (filters) ->
        console.log 'get query', filters
        SearchFiltersService.getESQueryFromFilters(
          filters
        )
    }
  , []

  {esQuery} = useStream ->
    esQuery: esQueryStream

  console.log 'esquery', esQuery

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
