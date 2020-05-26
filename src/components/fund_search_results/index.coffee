{z} = require 'zorium'
_map = require 'lodash/map'
_orderBy = require 'lodash/orderBy'
_take = require 'lodash/take'

$table = require '../table'
$tags = require '../tags'
$fundSearchResultsMobileRow = require '../fund_search_results_mobile_row'
FormatService = require '../../services/format'
config = require '../../config'

if window?
  require './index.styl'

VISIBLE_FOCUS_AREAS_COUNT = 2

module.exports = $fundSearchResults = ({model, router, rows}) ->
  z '.z-fund-search-results',
    z $table,
      model: model
      data: rows
      onRowClick: (e, i) ->
        router.goFund rows[i]
      mobileRowRenderer: $fundSearchResultsMobileRow
      columns: [
        {key: 'name', name: model.l.get 'general.name', width: 240, isFlex: true}
        {
          key: 'focusAreas', name: model.l.get 'fund.focusAreas'
          width: 400, passThroughSize: true,
          content: ({row, size}) ->
            focusAreas = _orderBy row.fundedNteeMajors, 'count', 'desc'
            tags = _map focusAreas, ({key}) ->
              {
                text: model.l.get "nteeMajor.#{key}"
                color: config.NTEE_MAJOR_COLORS[key]
              }
            z $tags, {tags, size, maxVisibleCount: VISIBLE_FOCUS_AREAS_COUNT}
        }
        {
          key: 'assets', name: model.l.get 'org.assets'
          width: 150
          content: ({row}) ->

            FormatService.abbreviateDollar row.assets
        }
        {
          key: 'grantMedian', name: model.l.get 'fund.medianGrant'
          width: 170
          content: ({row}) ->
            FormatService.abbreviateDollar row.lastYearStats?.grantMedian
        }
        {
          key: 'grantSum', name: model.l.get 'fund.grantsPerYear'
          width: 150
          content: ({row}) ->
            FormatService.abbreviateDollar row.lastYearStats?.grantSum
        }
      ]
