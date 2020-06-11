/* eslint-disable
    no-unused-vars,
*/
// TODO: This file was created by bulk-decaffeinate.
// Fix any style issues and re-enable lint.
import { z, lazy, Suspense, Boundary } from 'zorium'

import $spinner from 'frontend-shared/components/spinner'

import config from '../../config'
const $pie = lazy(() => import(/* webpackChunkName: "nivo" */'@nivo/pie').then(({ ResponsivePie }) => ResponsivePie))

if (typeof window !== 'undefined') { require('./index.styl') }

export default function $chartPie ({ data, colors }) {
  return z('.z-chart-pie', [
    (typeof window !== 'undefined' && window !== null)
      ? z(Boundary, { fallback: z('.error', 'err') },
        z(Suspense, { fallback: $spinner },
          z($pie, {
            data,
            innerRadius: 0.5,
            colors,
            enableRadialLabels: false,
            enableSlicesLabels: false
          }
          )
        )
      ) : undefined
  ])
}
