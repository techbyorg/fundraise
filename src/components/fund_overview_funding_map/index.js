import { z } from 'zorium'
import * as _ from 'lodash-es'

import $chartUsMap from '../chart_us_map'

if (typeof window !== 'undefined' && window !== null) {
  require('./index.styl')
}

export default function $fundOverviewNteePie ({ irsFund }) {
  const data = _.map(irsFund?.fundedStates, ({ key, sum }) => ({
    id: key,
    value: sum
  }))

  return z('.z-fund-overview-funding-map', [
    z($chartUsMap, { data })
  ])
};
