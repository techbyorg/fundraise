import { z, useContext, useMemo, useStream } from 'zorium'
import * as _ from 'lodash-es'
import * as rx from 'rxjs/operators'

import $table from 'frontend-shared/components/table'
import FormatService from 'frontend-shared/services/format'

import RouterService from '../..services/router'
import context from '../../context'

if (typeof window !== 'undefined' && window !== null) {
  require('./index.styl')
}

export default function $entityGrants ({ entity, entityStream, entityType }) {
  const { model, browser, lang } = useContext(context)

  const { contributionsStream } = useMemo(() => ({
    contributionsStream: entityStream.pipe(rx.switchMap(entity => {
      if (entityType === 'irsNonprofit') {
        return model.irsContribution.getAllByToId(entity.ein, { limit: 100 })
      } else {
        return model.irsContribution.getAllByFromEin(entity.ein, { limit: 100 })
      }
    }))
  }), [])

  const { contributions, breakpoint } = useStream(() => ({
    contributions: contributionsStream,
    breakpoint: browser.getBreakpoint()
  }))

  return z('.z-entity-grants', [
    z('.grants', [
      z($table, {
        breakpoint,
        data: contributions?.nodes,
        mobileRowRenderer: entityType === 'irsNonprofit'
          ? $nonprofitGrantsMobileRow
          : $fundGrantsMobileRow,
        columns: _.filter([
          {
            key: 'amount',
            name: lang.get('general.amount'),
            width: 150,
            content ({ row }) {
              return `$${FormatService.number(row.amount)}`
            }
          },
          entityType === 'irsNonprofit' && {
            key: 'fromEin',
            name: 'Name',
            width: 300,
            content: $entityGrantFundName
          },
          entityType === 'irsFund' && {
            key: 'toId',
            name: 'Name',
            width: 300,
            content: $entityGrantNonprofitName
          },
          {
            key: 'purpose',
            name: lang.get('entityGrants.purpose'),
            width: 300,
            isFlex: true,
            content ({ row }) {
              return z('.purpose',
                z('.category', lang.get(`nteeMajor.${row.nteeMajor}`)),
                z('.text', row.purpose))
            }
          },
          entityType === 'irsFund' && {
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
        ])
      })
    ])
  ])
};

function $entityGrantNonprofitName ({ row }) {
  const { model, router } = useContext(context)
  const hasEin = model.irsNonprofit.isEin(row.toId)
  return router.linkIfHref(z('.name', {
    href: hasEin && router.get('nonprofitByEin', {
      ein: row.toId,
      slug: _.kebabCase(row.toName)
    })
  }, row.toName))
}

function $entityGrantFundName ({ row }) {
  const { router } = useContext(context)
  return router.linkIfHref(z('.name', {
    href: RouterService.getFund(row.irsFund, null, router)
  }, row.irsFund?.name))
}

function $fundGrantsMobileRow ({ row }) {
  return z($entityGrantsMobileRow, { row, entityType: 'irsFund' })
}

function $nonprofitGrantsMobileRow ({ row }) {
  return z($entityGrantsMobileRow, { row, entityType: 'irsNonprofit' })
}

function $entityGrantsMobileRow ({ row, entityType }) {
  const { lang } = useContext(context)
  return z('.z-entity-grants-mobile-row', [
    z('.name', [
      entityType === 'irsNonprofit'
        ? z($entityGrantFundName, { row })
        : z($entityGrantNonprofitName, { row })
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
