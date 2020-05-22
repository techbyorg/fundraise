{z} = require 'zorium'
colors = require '../../colors'

$icon = require '../icon'

if window?
  require './index.styl'

module.exports = $buttonMenu = ({model, color, onclick, isAlignedLeft = true}) ->
  z '.z-button-menu',
    z $icon,
      isAlignedLeft: isAlignedLeft
      icon: 'menu'
      color: color or colors.$header500Icon
      hasRipple: true
      onclick: (e) ->
        e.preventDefault()
        if onclick
          onclick()
        else
          model.drawer.open()
