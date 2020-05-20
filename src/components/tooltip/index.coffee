{z, classKebab, useEffect, useRef, useStream} = require 'zorium'
_uniq = require 'lodash/uniq'
RxBehaviorSubject = require('rxjs/BehaviorSubject').BehaviorSubject

$icon = require '../icon'
colors = require '../../colors'

if window?
  require './index.styl'

module.exports = Tooltip = (props) ->
  {model, key, anchor, offset, isVisibleStream, zIndex
    $title, $content, initialPosition} = props

  $$el = useRef()

  {anchorStream, transformStream} = useMemo ->
    {
      anchorStream: new RxBehaviorSubject null
      transformStream: new RxBehaviorSubject null
    }
  , []

  useEffect ->
    setTimeout ->
      checkIsReady = ->
        if $$el and $$el.current.clientWidth
          _setPosition $$el
        else
          setTimeout checkIsReady, 100
      checkIsReady()
    , 0 # give time for re-render...

    return null
  , []

  {isVisible, anchor, transform} = useStream ->
    isVisible: isVisibleStream
    anchor: anchorStream
    transform: transformStream

  _setPosition = ($$el) ->
    isPositionSet = true
    rect = $$el.current.getBoundingClientRect()
    windowSize = model.window.getSize().getValue()
    position = {x: rect.left, y: rect.top}
    size = {width: rect.width, height: rect.height}
    anchor = anchor or getAnchor position, windowSize, size
    anchorStream.next anchor
    transformStream.next getTransform position, anchor
    isVisibleStream.next true

  getAnchor = (position, windowSize, size) ->
    width = windowSize?.width
    height = windowSize?.height
    xAnchor = if position?.x < size.width / 2 \
              then 'left'
              else if position?.x > width - size.width# / 2
              then 'right'
              else 'center'
    yAnchor = if position?.y < size.height \
              then 'top'
              else if position?.y > height or xAnchor is 'center'
              then 'bottom'
              else 'center'
    "#{yAnchor}-#{xAnchor}"

  getTransform = (position, anchor) ->
    anchorParts = anchor.split('-')
    xPercent = if anchorParts[1] is 'left' \
               then 0
               else if anchorParts[1] is 'center'
               then -50
               else -100
    yPercent = if anchorParts[0] is 'top' \
               then 0
               else if anchorParts[0] is 'center'
               then -50
               else -100
    xPx = (position?.x or 8) + (offset?.left or 0)
    yPx = position?.y + (offset?.top or 0)
    "translate(#{xPercent}%, #{yPercent}%) translate(#{xPx}px, #{yPx}px)"

  close = ->
    completedTooltips = try
      model.cookie.get('completedTooltips').split(',')
    catch error
      []
    completedTooltips ?= []
    model.cookie.set 'completedTooltips', _uniq(
      completedTooltips.concat [key]
    ).join(',')

    isVisibleStream.next false
    model.tooltip.set$ null

  style =
    top: if transform then 0 else "#{initialPosition?.y or 0}px"
    left: if transform then 0 else "#{initialPosition?.x or 0}px"
    transform: transform
    webkitTransform: transform

  if zIndex
    style.zIndex = zIndex

  z ".z-tooltip.anchor-#{anchor}", {
    ref: $$el
    className: classKebab {isVisible}
    style: style
  },
    z '.close',
      z $icon,
        icon: 'close'
        size: '16px'
        isTouchTarget: false
        color: colors.$bgText54
        onclick: close
    z '.content',
      z '.title', $title
      $content
