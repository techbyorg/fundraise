{z, useRef, useEffect} = require 'zorium'
_defaults = require 'lodash/defaults'

$icon = require '../icon'
$button = require '../button'
config = require '../../config'
colors = require '../../colors'

# FIXME: allow another one to be opened when this is still closing
CLOSE_DELAY_MS = 450 # 0.45s for animation

if window?
  require './index.styl'

module.exports = Sheet = (props) ->
  {model, router, id, icon, message, submitButton, $content}

  $$el = useRef()

  useEffect ->
    $$el.classList.add 'is-visible'

    return null
  , []

  z '.z-sheet', {
    ref: $$el
    key: id
  },
    z '.overlay',
      onclick: ->
        $$el.classList.remove 'is-visible'
        setTimeout ->
          model.overlay.close {id}
        , CLOSE_DELAY_MS
    z '.sheet',
      z '.inner',
        if $content
          $content
        else
          [
            z '.content',
              z '.icon',
                z $icon,
                  icon: icon
                  color: colors.$primaryMain
                  isTouchTarget: false
              z '.message', message
            z '.actions',
              z $button,
                text: model.l.get 'general.notNow'
                isFullWidth: false
                onclick: ->
                  model.overlay.close()
              z $button, _defaults submitButton, {
                isFullWidth: false
                colors: {cText: colors.$primaryMain}
              }
          ]
