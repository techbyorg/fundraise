import { z, useEffect, useMemo } from 'zorium'
import * as Rx from 'rxjs'
import * as rx from 'rxjs/operators'

import $dropdown from 'frontend-shared/components/dropdown'

if (typeof window !== 'undefined' && window !== null) {
  require('./index.styl')
}

export default function $filterContentMinMax (props) {
  const {
    filterValueStr, resetValue, filter, valueStreams, filterValue,
    overlayAnchor, $$parentRef
  } = props

  const { minStream, maxStream } = useMemo(() => {
    const minStream = new Rx.BehaviorSubject(
      filterValue?.min || filter.minOptions[0].value
    )
    const maxStream = new Rx.BehaviorSubject(
      filterValue?.max || filter.maxOptions[0].value
    )
    valueStreams.next(Rx.combineLatest(
      minStream, maxStream,
      (...vals) => vals
    )
      .pipe(rx.map(function ([min, max]) {
        min = min && parseInt(min)
        max = max && parseInt(max)
        if (min || max) {
          return { min, max }
        }
      }))
    )

    return { minStream, maxStream }
  }, [])

  useEffect(() => {
    minStream.next(filterValue?.min || filter.minOptions[0].value)
    maxStream.next(filterValue?.max || filter.maxOptions[0].value)
  // need to recreate valueStreams when resetting
  }, [filterValueStr, resetValue])

  return z('.z-filter-content-min-max', [
    z('.flex', [
      z('.block', [
        z($dropdown, {
          $$parentRef,
          valueStream: minStream,
          options: filter.minOptions,
          anchor: overlayAnchor
        })
      ]),
      z('.dash', '-'),
      z('.block', [
        z($dropdown, {
          $$parentRef,
          valueStream: maxStream,
          options: filter.maxOptions,
          anchor: overlayAnchor
        })
      ])
    ])
  ])
}
