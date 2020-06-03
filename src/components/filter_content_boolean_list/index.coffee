import {z, classKebab, useMemo} from 'zorium'
import * as _ from 'lodash'
import * as Rx from 'rxjs'
import * as rx from 'rxjs/operators'

import $checkbox from 'frontend-shared/components/checkbox'

if window?
  require './index.styl'

export default $filterContent = ({filterValueStr, valueStreams, filterValue}) ->
  {items} = useMemo ->
    list = filter.items
    items = _.map list, ({label}, key) =>
      valueStream = new Rx.BehaviorSubject(
        filterValue?[key]
      )
      {
        valueStream, label, key
      }

    valueStreams.next Rx.combineLatest(
      _.map items, 'valueStream'
      (vals...) -> vals
    ).pipe rx.map (vals) ->
      unless _.isEmpty _.filter(vals)
        _.zipObject _.map(list, 'key'), vals

    {items}
  , [filterValueStr] # need to recreate valueStreams when resetting

  z '.z-filter-content-boolean-list',
    z '.tap-items', {
      className: classKebab {isFullWidth: filter.field is 'subType'}
    },
      _.map items, ({valueStream, label, key}) =>
        isSelected = valueStream.getValue()
        z '.tap-item', {
          className: classKebab {
            isSelected
          }
          onclick: ->
            valueStream.next not isSelected
        },
          label or "FIXME: #{filter.id}"
