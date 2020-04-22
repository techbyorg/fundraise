z = require 'zorium'
_defaults = require 'lodash/defaults'

Icon = require '../icon'
Input = require '../input'
allColors = require '../../colors'


if window?
  require './index.styl'

module.exports = class PrimaryInput extends Input
  constructor: ->
    super arguments...
    @state = z.state isPasswordVisible: false
    @$eyeIcon = new Icon()

  render: (opts) =>
    {isPasswordVisible} = @state.getValue()

    optType = opts.type

    opts.type = if isPasswordVisible then 'text' else opts.type

    isFullWidth = opts.isFullWidth

    colors = opts.colors or
      # background: colors.$bgColor
      c200: allColors.$bgText54
      c500: allColors.$bgText
      c600: allColors.$bgText87
      c700: allColors.$bgText70
      ink: allColors.$bgText

    z '.z-primary-input', {
      className: z.classKebab {isFullWidth}
    },
      super _defaults opts, {
        isRaised: true
        isFloating: true
        isDark: true
        colors: colors
      }
      if optType is 'password'
        z '.make-visible', {
          onclick: =>
            @state.set isPasswordVisible: not isPasswordVisible
        },
          z @$eyeIcon,
            icon: 'eye'
            color: colors.ink
      else if opts.onInfo
        z '.make-visible', {
          onclick: ->
            opts.onInfo()
        },
          z @$eyeIcon,
            icon: 'help'
            color: colors.ink
