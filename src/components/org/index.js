// TODO: This file was created by bulk-decaffeinate.
// Sanity-check the conversion and remove this comment.
import { z, classKebab, useContext, useMemo, useStream } from 'zorium'
import * as _ from 'lodash-es'
import * as Rx from 'rxjs'
import * as rx from 'rxjs/operators'

import $avatar from 'frontend-shared/components/avatar'
import $dropdown from 'frontend-shared/components/dropdown'
import FormatService from 'frontend-shared/services/format'
import context from '../../context'

if (typeof window !== 'undefined' && window !== null) {
  require('./index.styl')
}

export default function $org ({ irsOrgStream }) {
  const { model, lang } = useContext(context)

  var {
    irsOrg990StatsStream, metricValueStreams, contributionsStream,
    irsOrg990StatsAndMetricStream
  } = useMemo(function () {
    metricValueStreams = new Rx.ReplaySubject(1)
    metricValueStreams.next(Rx.of('revenue'))

    return {
      metricValueStreams,
      contributionsStream: irsOrgStream.pipe(rx.switchMap(irsOrg => model.irsContribution.getAllByToId(irsOrg.ein))
      )
    }
  }
  , [])

  const {
    me, contributions, metric, irsOrg, irsPersons, graphData, irsOrg990Stats,
    org
  } = useStream(() => ({
    me: model.user.getMe(),
    contributions: contributionsStream,
    metric: metricValueStreams.pipe(rx.switchAll()),

    graphData: irsOrg990StatsAndMetricStream.pipe(rx.map(function (...args) {
      let stats
      let metric;
      [stats, metric] = Array.from(args[0])
      const minVal = _.min(stats?.[metric])
      const low = minVal < 0 ? minVal : 0

      return {
        labels: stats?.years,
        series: stats?.[metric],
        low
      }
    })),

    irsOrg: irsOrgStream,
    irsOrg990Stats: null,

    irsPersons: irsOrgStream.pipe(rx.switchMap(irsOrg => {
      if (irsOrg) {
        return model.irsPerson.getAllByEin(irsOrg.ein)
          .pipe(rx.map(irsPersons => _.orderBy(irsPersons, 'compensation', 'desc'))
          )
      } else {
        return Rx.of(null)
      }
    })
    )
  }))

  console.log('abcd')

  return z('.z-org',
    irsOrg990Stats && !irsOrg990Stats.has990
      ? z('.no-990', lang.get('org.no990'))
      : z('.box.analytics',
        z('.header',
          lang.get('general.analytics'),
          z('.metric-dropdown',
            z($dropdown, {
              currentText: lang.get('org.changeMetric'),
              valueStreams: metricValueStreams,
              options: [
                { value: 'revenue', text: lang.get('metric.revenue') },
                { value: 'expenses', text: lang.get('metric.expenses') },
                { value: 'net', text: lang.get('metric.net') },
                { value: 'assets', text: lang.get('metric.assets') },
                { value: 'employeeCount', text: lang.get('metric.employeeCount') },
                { value: 'volunteerCount', text: lang.get('metric.volunteerCount') }
              ]
            }))),
        z('.content',
          z('.chart-header',
            lang.get(`metric.${metric}`) || 'Custom metric'), // FIXME
          z('.chart')),
        // if window? and graphData and graphData.series
        //   z $graph, {
        //     labels: graphData.labels
        //     series: [graphData.series]
        //     options:
        //       fullWidth: true
        //       low: graphData.low
        //       showArea: true
        //       lineSmooth:
        //         $graph.getChartist().Interpolation.monotoneCubic {
        //           fillHoles: false
        //         }
        //       axisY:
        //         onlyInteger: true
        //         showGrid: true
        //         # type: $graph.getChartist().FixedScaleAxis
        //         labelInterpolationFnc: (value) ->
        //           FormatService.abbreviateNumber value
        //       axisX:
        //         showLabel: true
        //         showGrid: false
        //   }
        z('.box.at-a-glance',
          z('.header',
            lang.get('org.atAGlance')),
          z('.content',
            z('.top-metrics',
              z('.metric',
                z('.value',
                  FormatService.number(irsOrg?.employeeCount || 0)),
                z('.name',
                  lang.get('org.employees'))
              ),
              z('.metric',
                z('.value',
                  '$',
                  FormatService.number(irsOrg?.assets)),
                z('.name',
                  lang.get('org.assets'))
              )
            ),
            z('.block',
              z('.title', lang.get('general.location')),
              z('.text', FormatService.location(irsOrg))),
            z('.block',
              z('.title', lang.get('general.category')),
              z('.text',
                lang.get(`nteeMajor.${irsOrg?.nteecc?.substr(0, 1)}`))
            ),
            z('.block',
              z('.title', lang.get('general.mission')),
              z('.text.mission', {
                className: classKebab({
                  isTruncated: irsOrg?.mission?.length > 50
                })
              },
                irsOrg?.mission)
            ),
            z('.block',
              z('.title',
                lang.get('org.lastReport', {
                  replacements: { year: irsOrg990Stats?.last?.year }
                })),
              z('.metrics',
                z('.metric',
                  z('.value',
                    '$',
                    FormatService.number(irsOrg990Stats?.last?.expenses)),
                  z('.name',
                    lang.get('metric.expenses'))
                ),
                z('.metric',
                  z('.value',
                    '$',
                    FormatService.number(irsOrg990Stats?.last?.revenue)),
                  z('.name',
                    lang.get('metric.revenue'))
                )
              )
            )
          )
        ),

        z('.box',
          z('.header',
            lang.get('general.people')),
          z('.content',
            _.map(irsPersons, irsPerson => z('.person',
              z('.avatar',
                z($avatar, { user: irsPerson })),
              z('.info',
                z('.name', irsPerson.name),
                z('.title', irsPerson.title)),
              z('.right',
                '$',
                FormatService.number(irsPerson.compensation))
            ))
          )
        )
      )
  )
};
