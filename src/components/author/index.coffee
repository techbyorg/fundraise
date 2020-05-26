{z, classKebab, useContext} = require 'zorium'

$icon = require '../icon'
DateService = require '../../services/date'
colors = require '../../colors'
context = require '../../context'

if window?
  require './index.styl'

module.exports = $author = (props) ->
  {user, entityUser, time, isTimeAlignedLeft, onclick, isFullDate} = props
  {model} = useContext context

  isModerator = entityUser?.roleNames and
                (
                  entityUser.roleNames.indexOf('mod') isnt -1 or
                  entityUser.roleNames.indexOf('mods') isnt -1
                )

  z '.z-author', {onclick},
    if user?.username in ['austin', 'rachel']
      z '.icon',
        z $icon,
          icon: 'dev'
          color: colors.$bgText
          isTouchTarget: false
          size: '22px'
    else if user?.flags?.isModerator or isModerator
      z '.icon',
        z $icon,
          icon: 'mod'
          color: colors.$bgText
          isTouchTarget: false
          size: '22px'
    z '.name',
      model.user.getDisplayName user

    z '.icons',
      if user?.flags?.isSupporter
        z '.icon',
          z $supporterIcon,
            icon: 'heart'
            color: colors.$red500
            isTouchTarget: false
            size: '18px'
    z '.time', {
      className: classKebab {isAlignedLeft: isTimeAlignedLeft}
    },
      if time and isFullDate
      then DateService.format time, 'MMM yyyy'
      else if time
      then DateService.fromNow time
      else '...'
