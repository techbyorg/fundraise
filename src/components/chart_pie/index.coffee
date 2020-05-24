{z, lazy, Suspense, Boundary} = require 'zorium'
$pie = lazy -> (`import(/* webpackChunkName: "nivo" */'@nivo/pie').then(({ResponsivePie}) => ResponsivePie)`)

$spinner = require '../spinner'
config = require '../../config'

if window?
  require './index.styl'

module.exports = $chartPie = ({data, colors}) ->
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
