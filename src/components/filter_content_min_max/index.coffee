import {z, classKebab, useMemo} from 'zorium'
import * as Rx from 'rxjs'
import * as rx from 'rxjs/operators'

import $dropdown from 'frontend-shared/components/dropdown'

import colors from '../../colors'

if window?
  require './index.styl'

export default $filterContent = (props) ->
  {filterValueStr, filter, valueStreams, filterValue,
    overlayAnchor, $$parentRef} = props

  {minStream, maxStream} = useMemo ->
    minStream = new Rx.BehaviorSubject filterValue?.min or filter.minOptions[0].value
    maxStream = new Rx.BehaviorSubject filterValue?.max or filter.maxOptions[0].value
    valueStreams.next Rx.combineLatest(
      minStream, maxStream, (vals...) -> vals
    ).pipe rx.map ([min, max]) ->
      min = min and parseInt min
      max = max and parseInt max
      if min or max
        {min, max}

    {minStream, maxStream}
  , [filterValueStr] # need to recreate valueStreams when resetting

  z '.z-filter-content-min-max',
    z '.flex',
      z '.block',
        z $dropdown, {
          $$parentRef
          valueStream: minStream
          options: filter.minOptions
          anchor: overlayAnchor
        }
      z '.dash', '-'
      z '.block',
        z $dropdown, {
          $$parentRef
          valueStream: maxStream
          options: filter.maxOptions
          anchor: overlayAnchor
        }

