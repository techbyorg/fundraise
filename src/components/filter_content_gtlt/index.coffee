import {z, classKebab, useMemo} from 'zorium'
import * as Rx from 'rxjs'
import * as rx from 'rxjs/operators'

import $icon from 'frontend-shared/components/icon'
import $input from 'frontend-shared/components/input'
import {
  chevronRightIconPath, chevronLeftIconPath
} from 'frontend-shared/components/icon/paths'

import colors from '../../colors'

if window?
  require './index.styl'

export default $filterContent = ({valueStreams, filterValue}) ->
  {operatorStream, valueStream} = useMemo ->
    operatorStream = new Rx.BehaviorSubject filterValue?.operator
    valueStream = new Rx.BehaviorSubject filterValue?.value or ''
    valueStreams.next Rx.combineLatest(
      operatorStream, valueStream, (vals...) -> vals
    ).pipe rx.map ([operator, value]) ->
      if operator or value
        {operator, value}

    {operatorStream, valueStream}
  , []

  operator = filterValue?.operator

  z '.z-filter-content-gtlt',
    z '.label',
      z '.text', 'gtlt' # FIXME
      z '.operators',
        z '.operator', {
          className: classKebab {
            isSelected: operator is 'gt'
          }
          onclick: =>
            operatorStream.next 'gt'
        },
          z $icon,
            icon: chevronRightIconPath
            size: '20px'
            color: if operator is 'gt' \
                    then colors.$secondaryMainText \
                    else colors.$bgText38
        z '.operator', {
          className: classKebab {
            isSelected: operator is 'lt'
          }
          onclick: =>
            operatorStream.next 'lt'
        },
          z $icon,
            icon: chevronLeftIconPath
            size: '20px'
            color: if operator is 'lt' \
                    then colors.$secondaryMainText \
                    else colors.$bgText38
      z '.operator-input-wide',
        z $input, {
          valueStream: valueStream
          type: 'number'
          height: '24px'
        }

