import {z, classKebab, useContext, useMemo, useStream} from 'zorium'
import _orderBy from 'lodash/orderBy'
import _map from 'lodash/map'
import _min from 'lodash/min'
RxReplaySubject = require('rxjs/ReplaySubject').ReplaySubject
RxObservable = require('rxjs/Observable').Observable
require 'rxjs/add/observable/combineLatest'
require 'rxjs/add/observable/of'

import $avatar from 'frontend-shared/components/avatar'
import $dropdown from 'frontend-shared/components/dropdown'
import FormatService from 'frontend-shared/services/format'
import context from '../../context'

if window?
  require './index.styl'

export default $org = ({irsOrgStream}) ->
  {model, lang} = useContext context

  {irsOrg990StatsStream, metricValueStreams, contributionsStream,
    irsOrg990StatsAndMetricStream} = useMemo ->

    metricValueStreams = new RxReplaySubject 1
    metricValueStreams.next RxObservable.of 'revenue'

    irsOrg990StatsStream = irsOrgStream.switchMap (irsOrg) =>
      if irsOrg
        model.irsOrg990.getStatsByEin irsOrg.ein
      else
        RxObservable.of null

    {
      irsOrg990StatsStream
      metricValueStreams
      contributionsStream: irsOrgStream.switchMap (irsOrg) ->
        model.irsContribution.getAllByToId irsOrg.ein
      irsOrg990StatsAndMetricStream: RxObservable.combineLatest(
        irsOrg990StatsStream, metricValueStreams.switch(), (vals...) -> vals
      )
    }
  , []

  {me, contributions, metric, irsOrg, irsPersons, graphData, irsOrg990Stats
    org} = useStream ->
    me: model.user.getMe()
    contributions: contributionsStream
    metric: metricValueStreams.switch()
    graphData: irsOrg990StatsAndMetricStream.map ([stats, metric]) ->
      console.log stats, metric
      minVal = _min(stats?[metric])
      low = if minVal < 0 then minVal else 0

      {
        labels: stats?.years
        series: stats?[metric]
        low: low
      }
    irsOrg: irsOrgStream
    irsOrg990Stats: irsOrg990StatsStream
    irsPersons: irsOrgStream.switchMap (irsOrg) =>
      if irsOrg
        model.irsPerson.getAllByEin irsOrg.ein
        .map (irsPersons) ->
          _orderBy irsPersons, 'compensation', 'desc'
      else
        RxObservable.of null


  console.log 'irsOrg', metric, irsOrg, irsPersons
  console.log 'ORGID', org?.id
  console.log 'USERID', me?.id
  console.log graphData
  console.log 'contrib', contributions

  z '.z-org',
    if irsOrg990Stats and not irsOrg990Stats.has990
      z '.no-990', lang.get 'org.no990'
    else
      z '.box.analytics',
        z '.header',
          lang.get 'general.analytics'
          z '.metric-dropdown',
            z $dropdown, {
              currentText: lang.get 'org.changeMetric'
              valueStreams: metricValueStreams
              options: [
                {value: 'revenue', text: lang.get 'metric.revenue'}
                {value: 'expenses', text: lang.get 'metric.expenses'}
                {value: 'net', text: lang.get 'metric.net'}
                {value: 'assets', text: lang.get 'metric.assets'}
                {value: 'employeeCount', text: lang.get 'metric.employeeCount'}
                {value: 'volunteerCount', text: lang.get 'metric.volunteerCount'}
              ]
            }
        z '.content',
          z '.chart-header',
            lang.get("metric.#{metric}") or 'Custom metric' # FIXME
          z '.chart',
            # if window? and graphData and graphData.series
            #   z $graph, {
            #     labels: graphData.labels
            #     series: [graphData.series]
            #     options:
            #       fullWidth: true
            #       low: graphData.low
            #       showArea: true
            #       lineSmooth:
            #         $graph.getChartist().Interpolation.monotoneCubic {
            #           fillHoles: false
            #         }
            #       axisY:
            #         onlyInteger: true
            #         showGrid: true
            #         # type: $graph.getChartist().FixedScaleAxis
            #         labelInterpolationFnc: (value) ->
            #           FormatService.abbreviateNumber value
            #       axisX:
            #         showLabel: true
            #         showGrid: false
            #   }
        z '.box.at-a-glance',
          z '.header',
            lang.get 'org.atAGlance'
          z '.content',
            z '.top-metrics',
              z '.metric',
                z '.value',
                  FormatService.number irsOrg?.employeeCount or 0
                z '.name',
                  lang.get 'org.employees'
              z '.metric',
                z '.value',
                  '$'
                  FormatService.number irsOrg?.assets
                z '.name',
                  lang.get 'org.assets'
            z '.block',
              z '.title', lang.get 'general.location'
              z '.text', FormatService.location irsOrg
            z '.block',
              z '.title', lang.get 'general.category'
              z '.text',
                lang.get "nteeMajor.#{irsOrg?.nteecc?.substr(0, 1)}"
            z '.block',
              z '.title', lang.get 'general.mission'
              z '.text.mission', {
                className: classKebab {
                  isTruncated: irsOrg?.mission?.length > 50
                }
              },
                irsOrg?.mission
            z '.block',
              z '.title',
                lang.get 'org.lastReport', {
                  replacements: {year: irsOrg990Stats?.last?.year}
                }
              z '.metrics',
                z '.metric',
                  z '.value',
                    '$'
                    FormatService.number irsOrg990Stats?.last?.expenses
                  z '.name',
                    lang.get 'metric.expenses'
                z '.metric',
                  z '.value',
                    '$'
                    FormatService.number irsOrg990Stats?.last?.revenue
                  z '.name',
                    lang.get 'metric.revenue'

        z '.box',
          z '.header',
            lang.get 'general.people'
          z '.content',
            _map irsPersons, (irsPerson) ->
              z '.person',
                z '.avatar',
                  z $avatar, {user: irsPerson}
                z '.info',
                  z '.name', irsPerson.name
                  z '.title', irsPerson.title
                z '.right',
                  '$'
                  FormatService.number irsPerson.compensation
