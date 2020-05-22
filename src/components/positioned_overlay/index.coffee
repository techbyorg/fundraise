{z, classKebab, Portal, useEffect, useMemo, useRef, useStream} = require 'zorium'
_uniq = require 'lodash/uniq'
RxBehaviorSubject = require('rxjs/BehaviorSubject').BehaviorSubject

if window?
  require './index.styl'

module.exports = PositionedOverlay = (props) ->
  {model, $$targetRef, hasBackdrop, onClose, anchor, offset,
    zIndex, $content, repositionOnChangeStr} = props

  $$ref = useRef()

  {$$overlays, anchorStream, transformStream} = useMemo ->
    {
      $$overlays: document?.getElementById 'overlays-portal'
      anchorStream: new RxBehaviorSubject anchor
      transformStream: new RxBehaviorSubject null
    }
  , []

  useEffect ->
    targetBoundingRect = $$targetRef.current?.getBoundingClientRect() or {}
    refRect = $$ref.current.getBoundingClientRect()
    windowSize = model.window.getSize().getValue()
    position = {x: targetBoundingRect.left, y: targetBoundingRect.top}
    size = {width: refRect.width, height: refRect.height}
    targetSize = {width: targetBoundingRect.width, height: targetBoundingRect.height}
    anchor = anchor or getAnchor position, windowSize, size
    anchorStream.next anchor
    transformStream.next getTransform position, targetSize, anchor

    return null
  , [repositionOnChangeStr]

  {anchor, transform} = useStream ->
    anchor: anchorStream
    transform: transformStream


  getAnchor = (position, windowSize, size) ->
    width = windowSize?.width
    height = windowSize?.height
    xAnchor = if position?.x < size.width / 2 \
              then 'left' \
              else if position?.x > width - size.width \
              then 'right' \
              else 'center'
    yAnchor = if position?.y < size.height \
              then 'top' \
              else if position?.y > height or xAnchor is 'center' \
              then 'bottom' \
              else 'center'
    "#{yAnchor}-#{xAnchor}"

  getTransform = (position, targetSize, anchor) ->
    anchorParts = anchor.split('-')
    xPercent = if anchorParts[1] is 'left' \
               then 0 \
               else if anchorParts[1] is 'center' \
               then -50 \
               else -100
    yPercent = if anchorParts[0] is 'top' \
               then 0 \
               else if anchorParts[0] is 'center' \
               then -50 \
               else -100
    xOffset = if anchorParts[1] is 'left' \
               then 0 \
               else if anchorParts[1] is 'center' \
               then targetSize.width / 2 \
               else targetSize.width
    yOffset = if anchorParts[1] is 'top' \
               then 0 \
               else if anchorParts[1] is 'center' \
               then targetSize.height / 2 \
               else targetSize.height
    xPx = (position?.x or 8) + xOffset + (offset?.x or 0)
    yPx = position?.y + yOffset + (offset?.y or 0)
    "translate(#{xPercent}%, #{yPercent}%) translate(#{xPx}px, #{yPx}px)"

  style =
    top: 0
    left: 0
    transform: transform
    webkitTransform: transform

  if zIndex
    style.zIndex = zIndex

  z Portal, {target: $$overlays},
    z ".z-positioned-overlay.anchor-#{anchor}",
      if hasBackdrop
        z '.backdrop', {
          onclick: onClose
        }
      z '.content', {
        ref: $$ref
        style: style
      },
        $content
