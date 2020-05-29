import {z, lazy, Suspense, Boundary, useRef, useMemo, useStream, useEffect} from 'zorium'
import * as _ from 'lodash-es'
RxBehaviorSubject = require('rxjs/BehaviorSubject').BehaviorSubject

$choropleth = lazy ->
  Promise.all [
    `import(/* webpackChunkName: "nivo" */'@nivo/geo')
    .then(({ChoroplethCanvas}) => ChoroplethCanvas)`
    # canvas is more performant here. enough to matter on slow devices
    # due to us geojson

    fetch(
      # https://github.com/hrbrmstr/albersusa
      # ogr2ogr ./us_states.json ./composite_us_states.geojson -simplify 0.05 -sql "SELECT iso_3166_2 as id, name FROM composite_us_states"
      # then i manually changed the numberic ids to the two letter code
      'https://fdn.uno/d/data/us_states.json?1'
    ).then (response) -> response.json()
  ]
  .then ([$choropleth, {features}]) ->
    ({width, height, data, min, max}) ->
      z $choropleth,
        data: data
        width: width
        height: height
        features: features
        theme: {}
        colors: "nivo"
        domain: [ min, max ]
        unknownColor: colors.getRawColor colors.$bgText12
        colors: [
          '#91e0f4', '#81caef', '#6fafe6', '#5e9de7', '#4a7ed5', '#3d6edb'
        ]
        label: "properties.name"
        valueFormat: (value) ->
          FormatService.abbreviateDollar Number(value)
        projectionScale: width * 1.2
        projectionType: 'albersUsa'
        borderWidth: 1
        borderColor: colors.getRawColor colors.$bgColor

import $spinner from 'frontend-shared/components/spinner'
import FormatService from 'frontend-shared/services/format'
import useRefSize from 'frontend-shared/services/use_ref_size'

import colors from '../../colors'
import config from '../../config'

if window?
  require './index.styl'

export default $chartUsMap = ({data}) ->
  $$ref = useRef()

  {min, max} = useMemo ->
    values = _.map data, 'value'
    {
      min: _.min values
      max: _.max values
    }
  , [data]

  size = useRefSize $$ref

  z '.z-chart-us-map', {ref: $$ref},
    if window? and size
      z Boundary, {fallback: z '.error', 'err'},
        z Suspense, {fallback: $spinner},
          z $choropleth, {data, min, max, width: size.width, height: size.height}
