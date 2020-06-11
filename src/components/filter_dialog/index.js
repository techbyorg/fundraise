import {z, useContext, useMemo, useEffect, useRef, useStream} from 'zorium'
import * as Rx from 'rxjs'
import * as rx from 'rxjs/operators'

import $dialog from 'frontend-shared/components/dialog'
import $button from 'frontend-shared/components/button'

import $filterContent from '../filter_content'
import colors from '../../colors'
import context from '../../context'
import config from '../../config'

if window?
  require './index.styl'

export default $filterDialog = ({filter, onClose}) ->
  {lang} = useContext context

  {valueStreams, resetValueStream} = useMemo ->
    valueStreams = new Rx.ReplaySubject 1
    valueStreams.next filter.valueStreams.pipe rx.switchAll()
    {
      valueStreams
      resetValueStream: new Rx.BehaviorSubject ''
    }
  , []

  {resetValue, filterValue, hasValue} = useStream ->
    resetValue: resetValueStream
    filterValue: filter.valueStreams.pipe rx.switchAll()
    hasValue: valueStreams.pipe(
      rx.switchAll()
      rx.map (value) -> Boolean value
      rx.distinctUntilChanged (a, b) -> a is b # don't rerender a bunch
    )

  z '.z-filter-dialog',
    z $dialog,
      onClose: onClose
      $title: filter?.title or filter?.name
      $content:
        z '.z-filter-dialog_content',
          z '.content',
            z $filterContent, {
              filter, filterValue, valueStreams, resetValue
            }
      $actions:
        z '.z-filter-dialog_actions',
          z '.reset',
            if hasValue
              z $button,
                text: lang.get 'general.reset'
                onclick: =>
                  filter.valueStreams.next Rx.of null
                  valueStreams.next Rx.of null
                  resetValueStream.next Date.now()
          z '.save',
            z $button,
              text: lang.get 'general.save'
              isPrimary: true
              onclick: =>
                filter.valueStreams.next valueStreams.pipe rx.switchAll()
                resetValueStream.next Date.now()
                onClose()
