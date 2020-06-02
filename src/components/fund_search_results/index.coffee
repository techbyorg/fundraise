import {z, useContext} from 'zorium'
import * as _ from 'lodash-es'

import $table from 'frontend-shared/components/table'
import $tags from 'frontend-shared/components/tags'
import FormatService from 'frontend-shared/services/format'

import $fundSearchResultsMobileRow from '../fund_search_results_mobile_row'
import context from '../../context'
import {nteeColors} from '../../colors'

if window?
  require './index.styl'

VISIBLE_FOCUS_AREAS_COUNT = 2

export default $fundSearchResults = ({rows}) ->
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
          width: 400 # , passThroughSize: true,
          content: ({row}) ->
            focusAreas = _.orderBy row.fundedNteeMajors, 'count', 'desc'
            tags = _.map focusAreas, ({key}) ->
              {
                text: lang.get "nteeMajor.#{key}"
                background: nteeColors[key].bg
                color: nteeColors[key].fg
              }
            z $tags, {tags, maxVisibleCount: VISIBLE_FOCUS_AREAS_COUNT}
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
