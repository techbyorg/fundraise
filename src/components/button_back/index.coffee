{z} = require 'zorium'
colors = require '../../colors'

$icon = require '../icon'

module.exports = ButtonBack = (props) ->
  {router, color, onclick, fallbackPath, isAlignedLeft = true} = props

  z '.z-button-back',
    z $icon,
      isAlignedLeft: isAlignedLeft
      icon: 'back'
      color: color or colors.$header500Icon
      hasRipple: true
      onclick: (e) ->
        e.preventDefault()
        setTimeout ->
          if onclick
            onclick()
          else
            router.back {fallbackPath}
        , 0
