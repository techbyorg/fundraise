{z, useMemo, useEffect, useRef, useStream} = require 'zorium'
RxBehaviorSubject = require('rxjs/BehaviorSubject').BehaviorSubject
RxObservable = require('rxjs/Observable').Observable
require 'rxjs/add/observable/of'

$positionedOverlay = require '../positioned_overlay'
$filterContent = require '../filter_content'
$button = require '../button'
colors = require '../../colors'
config = require '../../config'

if window?
  require './index.styl'

module.exports = FilterPositionedOverlay = (props) ->
  {model, filter, onClose, $$targetRef} = props

  $$ref = useRef()

  {resetStream} = useMemo ->
    {resetStream: new RxBehaviorSubject null}
  , []

  useEffect ->
    $$ref.current.classList.add 'is-mounted'
  , []

  {value, resetValue} = useStream ->
    # HACK: do to keep filter value up-to-date when resetting
    value: filter.valueStreams.switch().do (updatedValue) ->
      filter.value = updatedValue
    resetValue: resetStream

  z '.z-filter-box-overlay',
    z $positionedOverlay,
      model: model
      onClose: onClose
      hasBackdrop: true
      $$targetRef: $$targetRef
      repositionOnChangeStr: filter.value
      anchor: 'top-left'
      offset:
        y: 8
      $content:
        z '.z-filter-positioned-overlay_content', {
          ref: $$ref
        },
          z '.content',
            z $filterContent, {
              model, filter, resetValue
            }
          if value
            z '.actions',
              z '.reset',
                if value
                  z $button,
                    text: model.l.get 'general.reset'
                    onclick: =>
                      filter.valueStreams.next RxObservable.of null
                      # setTimeout ->
                      #   resetStream.next Math.random()
                      # , 0
