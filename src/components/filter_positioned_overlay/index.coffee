import {z, useContext, useMemo, useEffect, useRef, useStream} from 'zorium'
import * as Rx from 'rxjs'
import * as rx from 'rxjs/operators'

import $positionedOverlay from 'frontend-shared/components/positioned_overlay'
import $button from 'frontend-shared/components/button'

import $filterContent from '../filter_content'
import colors from '../../colors'
import context from '../../context'
import config from '../../config'

if window?
  require './index.styl'

export default $filterPositionedOverlay = (props) ->
  {filter, onClose, $$targetRef} = props
  {lang} = useContext context

  $$ref = useRef()
  $$overlayRef = useRef() # have all child positionedOverlays be inside me

  {valueStreams} = useMemo ->
    valueStreams = new Rx.ReplaySubject 1
    valueStreams.next filter.valueStreams.pipe rx.switchAll()
    {
      valueStreams
    }
  , []

  useEffect ->
    setTimeout (-> $$ref.current.classList.add 'is-mounted'), 0
  , []

  {filterValue, hasValue} = useStream ->
    filterValue: filter.valueStreams.pipe rx.switchAll()
    hasValue: valueStreams.pipe(
      rx.switchAll()
      rx.map (value) -> Boolean value
      rx.distinctUntilChanged (a, b) -> a is b # don't rerender a bunch
    )

  z '.z-filter-positioned-overlay',
    z $positionedOverlay,
      onClose: onClose
      $$targetRef: $$targetRef
      $$ref: $$overlayRef
      repositionOnChangeStr: filter.value
      anchor: 'top-left'
      offset:
        y: 8
      $content:
        z '.z-filter-positioned-overlay_content', {
          ref: $$ref
        },
          z '.content',
            z '.title',
            filter?.title or filter?.name
            z $filterContent, {
              filter, filterValue, valueStreams, $$parentRef: $$overlayRef
            }
          z '.actions',
            z '.reset',
              if hasValue
                z $button,
                  text: lang.get 'general.reset'
                  onclick: =>
                    filter.valueStreams.next Rx.of null
                    valueStreams.next Rx.of null
            z '.save',
              z $button,
                text: lang.get 'general.save'
                isPrimary: true
                onclick: =>
                  filter.valueStreams.next valueStreams.pipe rx.switchAll()
                  onClose()
