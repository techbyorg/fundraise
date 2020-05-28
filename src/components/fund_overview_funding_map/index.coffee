import {z} from 'zorium'
import _map from 'lodash/map'

import $chartUsMap from '../chart_us_map'
import config from '../../config'

if window?
  require './index.styl'

export default $fundOverviewNteePie = ({irsFund}) ->
  data = _map irsFund?.fundedStates, ({key, sum}) ->
    {
      id: key
      value: sum
    }

  z '.z-fund-overview-funding-map',
    z $chartUsMap, {data}
