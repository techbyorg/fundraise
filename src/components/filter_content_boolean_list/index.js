// TODO: This file was created by bulk-decaffeinate.
// Sanity-check the conversion and remove this comment.
import { z, classKebab, useEffect, useMemo } from 'zorium'
import * as _ from 'lodash-es'
import * as Rx from 'rxjs'
import * as rx from 'rxjs/operators'

if (typeof window !== 'undefined' && window !== null) {
  require('./index.styl')
}

export default function $filterContentBooleanList (props) {
  const { filter, filterValueStr, resetValue, valueStreams, filterValue } = props

  var { items } = useMemo(function () {
    const list = filter.items
    items = _.map(list, ({ label }, key) => {
      const valueStream = new Rx.BehaviorSubject(
        filterValue?.[key]
      )
      return {
        valueStream, label, key
      }
    })

    valueStreams.next(Rx.combineLatest(
      _.map(items, 'valueStream'),
      (...vals) => vals).pipe(rx.map(function (vals) {
      if (!_.isEmpty(_.filter(vals))) {
        return _.zipObject(_.map(list, 'key'), vals)
      }
    })
    )
    )

    return { items }
  }
  , [])

  useEffect(() => _.forEach(items, ({ valueStream }, key) => {
    return valueStream.next(filterValue?.[key])
  })
  , [filterValueStr, resetValue]) // need to recreate valueStreams when resetting

  return z('.z-filter-content-boolean-list',
    z('.tap-items', {
      className: classKebab({ isFullWidth: filter.field === 'subType' })
    },
    _.map(items, ({ valueStream, label, key }) => {
      const isSelected = valueStream.getValue()
      return z('.tap-item', {
        className: classKebab({
          isSelected
        }),
        onclick () {
          return valueStream.next(!isSelected)
        }
      },
      label || `FIXME: ${filter.id}`)
    })
    )
  )
};
