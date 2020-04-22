z = require 'zorium'
_isEmpty = require 'lodash/isEmpty'
_map = require 'lodash/map'
_defaults = require 'lodash/defaults'

if window?
  require './index.styl'

Button = require '../button'
colors = require '../../colors'

module.exports = class Dialog
  constructor: ({@onLeave} = {}) ->
    @onLeave ?= (-> null)
    @$cancelButton = new Button()
    @$resetButton = new Button()
    @$submitButton = new Button()

  afterMount: (@$$el) =>
    @$$el.classList.add 'is-mounted'
    window.addEventListener 'keydown', @keyListener

  beforeUnmount: =>
    @$$el.classList.remove 'is-mounted'
    window.removeEventListener 'keydown', @keyListener

  keyListener: (e) =>
    if (e.key == 'Escape' or e.key == 'Esc' or e.keyCode == 27)
      e.preventDefault()
      @onLeave()

  render: (props) =>
    {$content, $title, cancelButton, resetButton, submitButton, isVanilla,
      isWide} = props
    $content ?= ''

    z '.z-dialog', {className: z.classKebab {isVanilla, isWide}},
      z '.backdrop', {
        onclick: =>
          @onLeave()
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
                className: z.classKebab {isFullWidth: cancelButton.isFullWidth}
              },
                z @$cancelButton, _defaults cancelButton, {
                  colors: {cText: colors.$primaryMain}
                }
            if resetButton
              z '.action', {
                className: z.classKebab {isFullWidth: resetButton.isFullWidth}
              },
                z @$resetButton, _defaults resetButton, {
                  colors: {cText: colors.$primaryMain}
                }
            if submitButton
              z '.action',
                z @$submitButton, _defaults submitButton, {
                  colors: {cText: colors.$primaryMain}
                }
