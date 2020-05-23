{z, classKebab, createPortal, useEffect, useMemo, useRef} = require 'zorium'
# _isEmpty = require 'lodash/isEmpty'
_map = require 'lodash/map'
# _defaults = require 'lodash/defaults'

if window?
  require './index.styl'

$button = require '../button'
colors = require '../../colors'

CLOSE_DELAY_MS = 450 # 0.45s for animation

module.exports = $dialog = (props) ->
  {onClose, $content = '', $title, cancelButton, resetButton, submitButton, isVanilla,
    isWide} = props

  $$ref = useRef()

  {$$overlays} = useMemo ->
    {
      $$overlays: document?.getElementById 'overlays-portal'
    }
  , []

  useEffect ->
    setTimeout (-> $$ref.current.classList.add 'is-mounted'), 0
    window.addEventListener 'keydown', keyListener

    return ->
      window.removeEventListener 'keydown', keyListener
  , []

  close = ->
    $$ref.current.classList.remove 'is-mounted'
    setTimeout ->
      onClose()
    , CLOSE_DELAY_MS

  keyListener = (e) ->
    if (e.key == 'Escape' or e.key == 'Esc' or e.keyCode == 27)
      e.preventDefault()
      close()

  createPortal(
    z '.z-dialog', {
      ref: $$ref
      className: classKebab {isVanilla, isWide}
    },
      z '.backdrop', {
        onclick: close
      }

      z '.dialog',
        z '.content',
          if $title
            z '.title',
              $title
          $content
        if cancelButton or submitButton
          z '.actions',
            if cancelButton
              z '.action', {
                className: classKebab {isFullWidth: cancelButton.isFullWidth}
              },
                z $button, _defaults cancelButton, {
                  colors: {cText: colors.$primaryMain}
                }
            if resetButton
              z '.action', {
                className: classKebab {isFullWidth: resetButton.isFullWidth}
              },
                z $button, _defaults resetButton, {
                  colors: {cText: colors.$primaryMain}
                }
            if submitButton
              z '.action',
                z $button, _defaults submitButton, {
                  colors: {cText: colors.$primaryMain}
                }
    $$overlays
  )
