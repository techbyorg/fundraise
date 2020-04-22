z = require 'zorium'
_defaults = require 'lodash/defaults'

Icon = require '../icon'
Input = require '../input'
colors = require '../../colors'


if window?
  require './index.styl'

module.exports = class SecondaryInput extends Input
  constructor: ->
    @state = z.state isPasswordVisible: false
    @$eyeIcon = new Icon()
    super

  render: (opts) =>
    {isPasswordVisible} = @state.getValue()

    optType = opts.type

    opts.type = if isPasswordVisible then 'text' else opts.type

    z '.z-secondary-input',
      super _defaults opts, {
        isFullWidth: true
        isRaised: true
        isFloating: false
        isDark: true
        colors:
          c200: colors.$bgText54
          c500: colors.$bgText
          c600: colors.$bgText87
          c700: colors.$bgText70
          ink: colors.$bgText
      }
      if optType is 'password'
        z '.make-visible', {
          onclick: =>
            @state.set isPasswordVisible: not isPasswordVisible
        },
          z @$eyeIcon,
            icon: 'eye'
            color: colors.$bgText
