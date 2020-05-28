{z, useContext} = require 'zorium'
_map = require 'lodash/map'
_orderBy = require 'lodash/orderBy'
_take = require 'lodash/take'

$table = require 'frontend-shared/components/table'
$tags = require 'frontend-shared/components/tags'
FormatService = require 'frontend-shared/services/format'

$fundSearchResultsMobileRow = require '../fund_search_results_mobile_row'
context = require '../../context'
config = require '../../config'

if window?
  require './index.styl'

VISIBLE_FOCUS_AREAS_COUNT = 2

module.exports = $fundSearchResults = ({rows}) ->
  {lang, router} = useContext context

  z '.z-fund-search-results',
    z $table,
      data: rows
      onRowClick: (e, i) ->
        router.goFund rows[i]
      mobileRowRenderer: $fundSearchResultsMobileRow
      columns: [
        {key: 'name', name: lang.get('general.name'), width: 240, isFlex: true}
        {
          key: 'focusAreas', name: lang.get 'fund.focusAreas'
          width: 400, passThroughSize: true,
          content: ({row, size}) ->
            focusAreas = _orderBy row.fundedNteeMajors, 'count', 'desc'
            tags = _map focusAreas, ({key}) ->
              {
                text: lang.get "nteeMajor.#{key}"
                color: config.NTEE_MAJOR_COLORS[key]
              }
            z $tags, {tags, size, maxVisibleCount: VISIBLE_FOCUS_AREAS_COUNT}
        }
        {
          key: 'assets', name: lang.get('org.assets')
          width: 150
          content: ({row}) ->

            FormatService.abbreviateDollar row.assets
        }
        {
          key: 'grantMedian', name: lang.get('fund.medianGrant')
          width: 170
          content: ({row}) ->
            FormatService.abbreviateDollar row.lastYearStats?.grantMedian
        }
        {
          key: 'grantSum', name: lang.get('fund.grantsPerYear')
          width: 150
          content: ({row}) ->
            FormatService.abbreviateDollar row.lastYearStats?.grantSum
        }
      ]
