{z, classKebab, useEffect, useStream} = require 'zorium'
_uniq = require 'lodash/uniq'
RxBehaviorSubject = require('rxjs/BehaviorSubject').BehaviorSubject

$icon = require '../icon'
colors = require '../../colors'

if window?
  require './index.styl'

# FIXME: use $positionedOverlay
module.exports = Tooltip = (props) ->
  {model, $$target, key, anchor, offset, isVisibleStream, zIndex
    $title, $content} = props

  close = ->
    completedTooltips = try
      model.cookie.get('completedTooltips').split(',')
    catch error
      []
    completedTooltips ?= []
    model.cookie.set 'completedTooltips', _uniq(
      completedTooltips.concat [key]
    ).join(',')
    $positionedOverlay.close()

    isVisibleStream.next false
  z ".z-tooltip.anchor-#{anchor}", {
    ref: $$target
    className: classKebab {isVisible}
    style: style
  },
    z $positionedOverlay,
      $content:
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
