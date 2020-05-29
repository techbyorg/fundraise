import {z, useContext, useMemo, useStream} from 'zorium'
import * as Rx from 'rxjs'
import * as rx from 'rxjs/operators'

import $sheet from 'frontend-shared/components/sheet'
import $button from 'frontend-shared/components/button'

import $filterContent from '../filter_content'
import colors from '../../colors'
import context from '../../context'
import config from '../../config'

if window?
  require './index.styl'

export default $filterContentSheet = ({id, filter, onClose}) ->
  {lang} = useContext context

  {valueStreams} = useMemo ->
    valueStreams = new Rx.ReplaySubject 1
    valueStreams.next filter.valueStreams.pipe rx.switchAll()
    {
      valueStreams
    }
  , []

  {filterValue, hasValue} = useStream ->
    filterValue: filter.valueStreams.pipe rx.switchAll()
    hasValue: valueStreams.pipe(
      rx.switchAll()
      rx.map (value) -> Boolean value
      rx.distinctUntilChanged (a, b) -> a is b # don't rerender a bunch
    )

  z '.z-filter-content-sheet',
    key: filter.id
    z $sheet,
      id: filter.id
      onClose: onClose
      $content:
        z '.z-filter-content-sheet_sheet',
          z '.actions',
            z '.reset',
              if hasValue
                z $button,
                  text: lang.get 'general.reset'
                  onclick: ->
                    filter.valueStreams.next Rx.of null
                    valueStreams.next Rx.of null
            z '.save',
              z $button,
                text: lang.get 'general.save'
                isPrimary: true
                onclick: ->
                  filter.valueStreams.next valueStreams.pipe rx.switchAll()
                  onClose()
          z '.title',
            filter?.title or filter?.name
          z $filterContent, {
            filter, filterValue, valueStreams, overlayAnchor: 'bottom-left'
          }
