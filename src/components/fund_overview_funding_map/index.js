import {z} from 'zorium'
import * as _ from 'lodash-es'

import $chartUsMap from '../chart_us_map'
import config from '../../config'

if window?
  require './index.styl'

export default $fundOverviewNteePie = ({irsFund}) ->
  data = _.map irsFund?.fundedStates, ({key, sum}) ->
    {
      id: key
      value: sum
    }

  z '.z-fund-overview-funding-map',
    z $chartUsMap, {data}
