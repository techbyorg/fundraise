{z, useContext, useMemo, useEffect, useRef, useStream} = require 'zorium'
RxBehaviorSubject = require('rxjs/BehaviorSubject').BehaviorSubject
RxReplaySubject = require('rxjs/ReplaySubject').ReplaySubject
RxObservable = require('rxjs/Observable').Observable
require 'rxjs/add/observable/of'

$positionedOverlay = require 'frontend-shared/components/positioned_overlay'
$button = require 'frontend-shared/components/button'

$filterContent = require '../filter_content'
colors = require '../../colors'
context = require '../../context'
config = require '../../config'

if window?
  require './index.styl'

module.exports = $filterContentPositionedOverlay = (props) ->
  {filter, onClose, $$targetRef} = props
  {lang} = useContext context

  $$ref = useRef()
  $$overlayRef = useRef() # have all child positionedOverlays be inside me

  {valueStreams} = useMemo ->
    valueStreams = new RxReplaySubject 1
    valueStreams.next filter.valueStreams.switch()
    {
      valueStreams
    }
  , []

  useEffect ->
    setTimeout (-> $$ref.current.classList.add 'is-mounted'), 0
  , []

  {filterValue, hasValue} = useStream ->
    filterValue: filter.valueStreams.switch()
    hasValue: valueStreams.switch().map (value) -> Boolean value
              .distinctUntilChanged((a, b) -> a is b) # don't rerender a bunch

  z '.z-filter-content-positioned-overlay',
    z $positionedOverlay,
      onClose: onClose
      $$targetRef: $$targetRef
      $$ref: $$overlayRef
      repositionOnChangeStr: filter.value
      anchor: 'top-left'
      offset:
        y: 8
      $content:
        z '.z-filter-content-positioned-overlay_content', {
          ref: $$ref
        },
          z '.content',
            z $filterContent, {
              filter, filterValue, valueStreams, $$parentRef: $$overlayRef
            }
          z '.actions',
            z '.reset',
              if hasValue
                z $button,
                  text: lang.get 'general.reset'
                  onclick: =>
                    filter.valueStreams.next RxObservable.of null
                    valueStreams.next RxObservable.of null
            z '.save',
              z $button,
                text: lang.get 'general.save'
                isPrimary: true
                onclick: =>
                  filter.valueStreams.next valueStreams.switch()
                  onClose()
