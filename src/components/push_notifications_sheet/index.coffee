{z} = require 'zorium'

$sheet = require '../sheet'
PushService = require '../../services/push'

module.exports = $pushNotificationSheet = ({model, router}) ->
  z '.z-push-notifications-sheet',
    z $sheet, {
      message: model.l.get 'pushNotificationsSheet.message'
      icon: 'notifications'
      submitButton:
        text: model.l.get 'pushNotificationsSheet.submitButtonText'
        onclick: ->
          PushService.register {model}
          .catch -> null
          .then ->
            model.overlay.close {action: 'complete'}
    }
