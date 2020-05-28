import {z, lazy, Suspense, Boundary} from 'zorium'
$pie = lazy -> (`import(/* webpackChunkName: "nivo" */'@nivo/pie').then(({ResponsivePie}) => ResponsivePie)`)

import $spinner from 'frontend-shared/components/spinner'

import config from '../../config'

if window?
  require './index.styl'

export default $chartPie = ({data, colors}) ->
  z '.z-chart-pie',
    if window?
      z Boundary, {fallback: z '.error', 'err'},
        z Suspense, {fallback: $spinner},
          z $pie,
            data: data
            innerRadius: 0.5
            colors: colors
            enableRadialLabels: false
            enableSlicesLabels: false
