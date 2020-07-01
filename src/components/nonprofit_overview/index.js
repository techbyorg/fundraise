import { z, useContext, useMemo, useStream } from 'zorium'
import * as Rx from 'rxjs'

import $dropdown from 'frontend-shared/components/dropdown'

import $fundOverviewLineChart from '../fund_overview_line_chart'
import context from '../../context'

if (typeof window !== 'undefined') { require('./index.styl') }

export default function $nonprofitOverview ({ entity }) {
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

  console.log('nonprofit ov', entity)

  return z('.z-nonprofit-overview', [
    z('.analytics', [
      z('.block', [
        z('.head', [
          z('.title', lang.get(`metric.${metric}`)),
          z('.metrics', [
            z($dropdown, {
              isPrimary: true,
              currentText: lang.get('nonprofitOverview.changeMetric'),
              valueStream: metricStream,
              options: [
                { value: 'assets', text: lang.get('metric.assets') },
                { value: 'employeeCount', text: lang.get('nonprofit.employees') },
                { value: 'volunteerCount', text: lang.get('nonprofit.volunteers') }
                // { value: 'officerSalaries', text: lang.get('metric.officerSalaries') }
              ]
            })
          ])
        ]),

        z($fundOverviewLineChart, { metric, entity })
      ])
    ])
  ])
}
