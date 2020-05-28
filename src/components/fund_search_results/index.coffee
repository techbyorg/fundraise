{z, useContext} = require 'zorium'
import _map from 'lodash/map'
import _orderBy from 'lodash/orderBy'
import _take from 'lodash/take'

import $table from 'frontend-shared/components/table'
import $tags from 'frontend-shared/components/tags'
import FormatService from 'frontend-shared/services/format'

import $fundSearchResultsMobileRow from '../fund_search_results_mobile_row'
import context from '../../context'
import config from '../../config'

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
