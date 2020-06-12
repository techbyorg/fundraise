import { z, useContext, useMemo, useStream } from 'zorium'
import * as Rx from 'rxjs'

import $dropdown from 'frontend-shared/components/dropdown'

import $fundOverviewLineChart from '../fund_overview_line_chart'
import $fundOverviewNteePie from '../fund_overview_ntee_pie'
import $fundOverviewFundingMap from '../fund_overview_funding_map'
import context from '../../context'

if (typeof window !== 'undefined') { require('./index.styl') }

export default function $fundOverview ({ irsFund }) {
  const { lang } = useContext(context)

  var { metricStream } = useMemo(function () {
    metricStream = new Rx.BehaviorSubject('assets')
    return {
      metricStream
    }
  }
  , [])

  const { metric } = useStream(() => ({
    metric: metricStream
  }))

  return z('.z-fund-overview', [
    z('.analytics', [
      z('.block', [
        z('.head', [
          z('.title', lang.get(`metric.${metric}`)),
          z('.metrics', [
            z($dropdown, {
              isPrimary: true,
              currentText: lang.get('fundOverview.changeMetric'),
              valueStream: metricStream,
              options: [
                { value: 'assets', text: lang.get('metric.assets') },
                { value: 'grantSum', text: lang.get('metric.grantSum') },
                { value: 'officerSalaries', text: lang.get('metric.officerSalaries') }
              ]
            })
          ])
        ]),

        z($fundOverviewLineChart, { metric, irsFund })
      ])
    ]),
    z('.grid', [
      z('.block.pie', [
        z('.head', [
          z('.title', lang.get('fundOverview.fundedNtee'))
        ]),
        z($fundOverviewNteePie, { irsFund })
      ]),
      z('.block.map', [
        z('.head',
          z('.title', lang.get('fundOverview.fundingMap'))),
        z($fundOverviewFundingMap, { irsFund })
      ])
    ])
  ])
}
