import { z, useContext, useStream } from 'zorium'
import * as _ from 'lodash-es'

import $table from 'frontend-shared/components/table'
import $tags from 'frontend-shared/components/tags'
import FormatService from 'frontend-shared/services/format'

import $fundSearchResultsMobileRow from '../fund_search_results_mobile_row'
import context from '../../context'
import { nteeColors } from '../../colors'

if (typeof window !== 'undefined' && window !== null) {
  require('./index.styl')
}

const VISIBLE_FOCUS_AREAS_COUNT = 2

export default function $fundSearchResults ({ rows }) {
  const { browser, lang, router } = useContext(context)

  const { breakpoint } = useStream(() => ({
    breakpoint: browser.getBreakpoint()
  }))

  return z('.z-fund-search-results', [
    z($table, {
      breakpoint,
      data: rows,
      rowHrefFn: (i) => router.getFund(rows[i]),
      mobileRowRenderer: $fundSearchResultsMobileRow,
      columns: [
        { key: 'name', name: lang.get('general.name'), width: 240, isFlex: true },
        {
          key: 'focusAreas',
          name: lang.get('irsFund.focusAreas'),
          width: 400, // , passThroughSize: true,
          content ({ row }) {
            const focusAreas = _.orderBy(row.fundedNteeMajors, 'count', 'desc')
            const tags = _.map(focusAreas, ({ key }) => ({
              text: lang.get(`nteeMajor.${key}`),
              background: nteeColors[key].bg,
              color: nteeColors[key].fg
            }))
            return z($tags, { tags, maxVisibleCount: VISIBLE_FOCUS_AREAS_COUNT })
          }
        },
        {
          key: 'assets',
          name: lang.get('nonprofit.assets'),
          width: 150,
          content ({ row }) {
            return FormatService.abbreviateDollar(row.assets)
          }
        },
        {
          key: 'grantMedian',
          name: lang.get('fund.medianGrant'),
          width: 170,
          content ({ row }) {
            return FormatService.abbreviateDollar(row.lastYearStats?.grantMedian)
          }
        },
        {
          key: 'grantSum',
          name: lang.get('fund.grantsPerYear'),
          width: 150,
          content ({ row }) {
            return FormatService.abbreviateDollar(row.lastYearStats?.grantSum)
          }
        }
      ]
    })
  ])
};
