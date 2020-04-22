z = require 'zorium'
_defaults = require 'lodash/defaults'

Ripple = require '../ripple'
Icon = require '../icon'
colors = require '../../colors'

if window?
  require './index.styl'

module.exports = class Button
  constructor: ->
    @$ripple = new Ripple()
    @$icon = new Icon()

  render: (options) =>
    {isPrimary, isSecondary, isFancy, isInverted, isDisabled, text, isFullWidth,
       isOutline, onclick, type, icon, heightPx, hasRipple} = options

    hasRipple ?= true
    heightPx ?= 36
    type ?= 'button'
    isFullWidth ?= true
    onclick ?= (-> null)

    z '.z-button', {
      className: z.classKebab {
        isFullWidth
        isOutline
        isPrimary
        isSecondary
        isFancy
        isInverted
        isDisabled
      }
      onclick: (e) =>
        unless isDisabled
          onclick(e)
    },

      z 'button.button', {
        attributes:
          type: type
          disabled: if isDisabled then true else undefined
        style:
          # lineHeight: "#{heightPx}px"
          minHeight: "#{heightPx}px"
      },
        if icon
          z '.icon',
            z @$icon,
            icon: icon
            isTouchTarget: false
            color: colors.$white # FIXME
        text
        if hasRipple
          @$ripple
