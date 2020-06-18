import { z, useContext } from 'zorium'

import $tags from 'frontend-shared/components/tags'
import FormatService from 'frontend-shared/services/format'

import context from '../../context'
import { nteeColors } from '../../colors'

if (typeof window !== 'undefined' && window !== null) {
  require('./index.styl')
}

export default function $orgSearchResultsMobileRow ({ row }) {
  const { lang } = useContext(context)

  const nteeMajor = row.nteecc?.substr(0, 1)
  const tags = nteeMajor && [{
    text: lang.get(`nteeMajor.${nteeMajor}`),
    background: nteeColors[nteeMajor].bg,
    color: nteeColors[nteeMajor].fg
  }]

  return z('.z-org-search-results-mobile-row', [
    z('.name', row.name),
    z('.location', FormatService.location(row)),
    z('.focus-areas',
      z($tags, { tags, maxVisibleCount: 1 })
    ),
    z('.stats', [
      z('.stat', [
        z('.title', lang.get('org.assets')),
        z('.value',
          FormatService.abbreviateDollar(row.assets))
      ]),
      z('.stat', [
        z('.title', lang.get('org.medianGrant')),
        z('.value',
          FormatService.abbreviateDollar(row.lastYearStats?.grantMedian)
        )
      ]),
      z('.stat', [
        z('.title', lang.get('org.grantsPerYear')),
        z('.value',
          FormatService.abbreviateDollar(row.lastYearStats?.grantSum)
        )
      ])
    ])
  ])
};
