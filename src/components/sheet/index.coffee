{z, createPortal, useContext, useRef, useMemo, useEffect} = require 'zorium'
_defaults = require 'lodash/defaults'

$icon = require '../icon'
$button = require '../button'
colors = require '../../colors'
context = require '../../context'
config = require '../../config'

CLOSE_DELAY_MS = 450 # 0.45s for animation

if window?
  require './index.styl'

module.exports = $sheet = (props) ->
  {icon, message, submitButton, onClose, $content} = props
  {lang} = useContext context

  $$ref = useRef()

  {$$overlays} = useMemo ->
    {
      $$overlays: document?.getElementById 'overlays-portal'
    }
  , []

  useEffect ->
    setTimeout (-> $$ref.current?.classList.add 'is-mounted'), 0
  , []

  close = ->
    $$ref.current?.classList.remove 'is-mounted'
    setTimeout ->
      onClose()
    , CLOSE_DELAY_MS

  createPortal(
    z '.z-sheet', {
      ref: $$ref
    },
      z '.backdrop',
        onclick: close
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
                  text: lang.get 'general.notNow'
                  isFullWidth: false
                  onclick: close
                z $button, _defaults submitButton, {
                  isFullWidth: false
                  colors: {cText: colors.$primaryMain}
                }
            ]
  $$overlays
  )
