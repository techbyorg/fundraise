import {z, useEffect,  useMemo} from 'zorium'
import * as _ from 'lodash-es'
import * as Rx from 'rxjs'
import * as rx from 'rxjs/operators'

import $checkbox from 'frontend-shared/components/checkbox'

if window?
  require './index.styl'

export default $filterContentList = (props) ->
  {filterValueStr, resetValue, filter, valueStreams, filterValue} = props

  {checkboxes} = useMemo ->
    list = filter.items

    checkboxes =  _.map list, ({label}, key) =>
      valueStream = new Rx.BehaviorSubject(
        filterValue?[key]
      )
      {key, valueStream, label}

    valueStreams.next Rx.combineLatest(
      _.map checkboxes, 'valueStream'
      (vals...) -> vals
    ).pipe rx.map (vals) ->
      unless _.isEmpty _.filter(vals)
        _.zipObject _.keys(list), vals

    {checkboxes}
  , []

  useEffect ->
    _.forEach checkboxes, ({key, valueStream}) =>
      valueStream.next filterValue?[key]
  , [filterValueStr, resetValue] # need to recreate valueStreams when resetting

  z '.z-filter-content-list',
    _.map checkboxes, ({valueStream, label}) ->
      z 'label.label',
        z '.checkbox',
          z $checkbox, {valueStream}
        z '.text', label or 'fixme'
