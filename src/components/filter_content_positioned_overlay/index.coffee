{z, useContext, useMemo, useEffect, useRef, useStream} = require 'zorium'
RxBehaviorSubject = require('rxjs/BehaviorSubject').BehaviorSubject
RxObservable = require('rxjs/Observable').Observable
require 'rxjs/add/observable/of'

$positionedOverlay = require '../positioned_overlay'
$filterContent = require '../filter_content'
$button = require '../button'
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

  {resetStream} = useMemo ->
    {resetStream: new RxBehaviorSubject null}
  , []

  useEffect ->
    setTimeout (-> $$ref.current.classList.add 'is-mounted'), 0
  , []

  {value, resetValue} = useStream ->
    # HACK: do to keep filter value up-to-date when resetting
    value: filter.valueStreams.switch().do (updatedValue) ->
      filter.value = updatedValue
    resetValue: resetStream

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
              filter, resetValue, $$parentRef: $$overlayRef
            }
          if value
            z '.actions',
              z '.reset',
                if value
                  z $button,
                    text: lang.get 'general.reset'
                    onclick: =>
                      filter.valueStreams.next RxObservable.of null
                      setTimeout ->
                        resetStream.next Math.random()
                      , 0
