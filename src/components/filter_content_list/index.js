// TODO: This file was created by bulk-decaffeinate.
// Sanity-check the conversion and remove this comment.
import { z, useEffect, useMemo } from 'zorium'
import * as _ from 'lodash-es'
import * as Rx from 'rxjs'
import * as rx from 'rxjs/operators'

import $checkbox from 'frontend-shared/components/checkbox'

if (typeof window !== 'undefined' && window !== null) {
  require('./index.styl')
}

export default function $filterContentList (props) {
  const { filterValueStr, resetValue, filter, valueStreams, filterValue } = props

  var { checkboxes } = useMemo(function () {
    const list = filter.items

    checkboxes = _.map(list, ({ label }, key) => {
      const valueStream = new Rx.BehaviorSubject(
        filterValue?.[key]
      )
      return { key, valueStream, label }
    })

    valueStreams.next(Rx.combineLatest(
      _.map(checkboxes, 'valueStream'),
      (...vals) => vals).pipe(rx.map(function (vals) {
      if (!_.isEmpty(_.filter(vals))) {
        return _.zipObject(_.keys(list), vals)
      }
    })
    )
    )

    return { checkboxes }
  }
  , [])

  useEffect(() => _.forEach(checkboxes, ({ key, valueStream }) => {
    return valueStream.next(filterValue?.[key])
  })
  , [filterValueStr, resetValue]) // need to recreate valueStreams when resetting

  return z('.z-filter-content-list',
    _.map(checkboxes, ({ valueStream, label }) => z('label.label',
      z('.checkbox',
        z($checkbox, { valueStream })),
      z('.text', label || 'fixme')))
  )
};
