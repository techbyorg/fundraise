import { z, useContext, useMemo, useStream } from 'zorium'
import * as _ from 'lodash-es'
import * as rx from 'rxjs/operators'

import $table from 'frontend-shared/components/table'
import FormatService from 'frontend-shared/services/format'

import context from '../../context'

if (typeof window !== 'undefined' && window !== null) {
  require('./index.styl')
}

export default function $fundGrants ({ entity, entityStream }) {
  const { model, browser, lang } = useContext(context)

  const { contributionsStream } = useMemo(() => ({
    contributionsStream: entityStream.pipe(rx.switchMap(entity => model.irsContribution.getAllByFromEin(entity.ein, { limit: 100 })))
  })
  , [])

  const { contributions, breakpoint } = useStream(() => ({
    contributions: contributionsStream,
    breakpoint: browser.getBreakpoint()
  }))

  return z('.z-fund-grants', [
    z('.grants', [
      z($table, {
        breakpoint,
        data: contributions?.nodes,
        mobileRowRenderer: $fundGrantsMobileRow,
        columns: [
          {
            key: 'amount',
            name: lang.get('general.amount'),
            width: 150,
            content ({ row }) {
              return `$${FormatService.number(row.amount)}`
            }
          },
          {
            key: 'toId',
            name: 'Name',
            width: 300,
            content: $fundGrantName
          },
          {
            key: 'purpose',
            name: lang.get('fundGrants.purpose'),
            width: 300,
            isFlex: true,
            content ({ row }) {
              return z('.purpose',
                z('.category', lang.get(`nteeMajor.${row.nteeMajor}`)),
                z('.text', row.purpose))
            }
          },
          {
            key: 'location',
            name: lang.get('general.location'),
            width: 150,
            content ({ row }) {
              return FormatService.location({
                city: row.toCity,
                state: row.toState
              })
            }
          },
          { key: 'year', name: lang.get('general.year'), width: 100 }
        ]
      })
    ])
  ])
};

function $fundGrantName ({ row }) {
  const { model, router } = useContext(context)
  let hasEin = model.irsOrg.isEin(row.toId)
  hasEin = false // FIXME: add org page
  const nameTag = hasEin ? 'a' : 'div'
  const nameFn = hasEin ? router.link : n => n
  return nameFn(z(`${nameTag}.name`, {
    href: hasEin ? router.get('orgByEin', {
      ein: row.toId,
      slug: _.kebabCase(row.toName)
    }) : undefined
  }, row.toName))
}

function $fundGrantsMobileRow ({ row }) {
  const { lang } = useContext(context)
  return z('.z-fund-grants-mobile-row', [
    z('.name', [
      z($fundGrantName, { row })
    ]),
    z('.location', [
      FormatService.location({
        city: row.toCity,
        state: row.toState
      })
    ]),
    z('.divider'),
    z('.purpose', [
      z('.category', lang.get(`nteeMajor.${row.nteeMajor}`)),
      z('.text', row.purpose)
    ]),
    z('.stats', [
      z('.stat', [
        z('.title', lang.get('general.year')),
        z('.value', row.year)
      ]),
      z('.stat', [
        z('.title', lang.get('general.amount')),
        z('.value',
          FormatService.abbreviateDollar(row.amount))
      ])
    ])
  ])
}
