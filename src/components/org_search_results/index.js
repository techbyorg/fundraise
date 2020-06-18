import { z, useContext, useStream } from 'zorium'

import $table from 'frontend-shared/components/table'
import $tags from 'frontend-shared/components/tags'
import FormatService from 'frontend-shared/services/format'

import $orgSearchResultsMobileRow from '../org_search_results_mobile_row'
import context from '../../context'
import { nteeColors } from '../../colors'

if (typeof window !== 'undefined' && window !== null) {
  require('./index.styl')
}

export default function $orgSearchResults ({ rows }) {
  const { browser, lang, router } = useContext(context)

  const { breakpoint } = useStream(() => ({
    breakpoint: browser.getBreakpoint()
  }))

  return z('.z-org-search-results', [
    z($table, {
      breakpoint,
      data: rows,
      onRowClick (e, i) {
        return router.goOrg(rows[i])
      },
      mobileRowRenderer: $orgSearchResultsMobileRow,
      columns: [
        { key: 'name', name: lang.get('general.name'), width: 240, isFlex: true },
        {
          key: 'focusAreas',
          name: lang.get('irsFund.focusAreas'),
          width: 400, // , passThroughSize: true,
          content ({ row }) {
            const nteeMajor = row.nteecc?.substr(0, 1)
            const tags = nteeMajor && [{
              text: lang.get(`nteeMajor.${nteeMajor}`),
              background: nteeColors[nteeMajor].bg,
              color: nteeColors[nteeMajor].fg
            }]
            return z($tags, { tags, maxVisibleCount: 1 })
          }
        },
        {
          key: 'assets',
          name: lang.get('org.assets'),
          width: 150,
          content ({ row }) {
            return FormatService.abbreviateDollar(row.assets)
          }
        },
        {
          key: 'grantMedian',
          name: lang.get('org.employees'),
          width: 170,
          content ({ row }) {
            return FormatService.abbreviateNumber(row.employeeCount)
          }
        },
        {
          key: 'grantSum',
          name: lang.get('org.volunteers'),
          width: 150,
          content ({ row }) {
            return FormatService.abbreviateNumber(row.volunteerCount)
          }
        }
      ]
    })
  ])
};
