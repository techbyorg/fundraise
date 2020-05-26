{z, useContext} = require 'zorium'

$sheet = require '../sheet'
PushService = require '../../services/push'
context = require '../../context'

module.exports = $pushNotificationSheet = ->
  {model, lang} = useContext context

  z '.z-push-notifications-sheet',
    z $sheet, {
      message: lang.get 'pushNotificationsSheet.message'
      icon: 'notifications'
      submitButton:
        text: lang.get 'pushNotificationsSheet.submitButtonText'
        onclick: ->
          PushService.register {model}
          .catch -> null
          .then ->
            model.overlay.close {action: 'complete'}
    }
