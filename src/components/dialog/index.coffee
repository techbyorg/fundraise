{z, classKebab, useEffect, useRef} = require 'zorium'
_isEmpty = require 'lodash/isEmpty'
_map = require 'lodash/map'
_defaults = require 'lodash/defaults'

if window?
  require './index.styl'

$button = require '../button'
colors = require '../../colors'

module.exports = Dialog = (props) ->
  {onClose, $content = '', $title, cancelButton, resetButton, submitButton, isVanilla,
    isWide} = props

  $$ref = useRef()

  useEffect ->
    $$ref.current.classList.add 'is-mounted'
    window.addEventListener 'keydown', keyListener

    return ->
      $$ref.current.classList.remove 'is-mounted'
      window.removeEventListener 'keydown', keyListener
  , []

  keyListener = (e) ->
    if (e.key == 'Escape' or e.key == 'Esc' or e.keyCode == 27)
      e.preventDefault()
      onClose()

  z '.z-dialog', {
    ref: $$ref
    className: classKebab {isVanilla, isWide}
  },
    z '.backdrop', {
      onclick: onClose
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
