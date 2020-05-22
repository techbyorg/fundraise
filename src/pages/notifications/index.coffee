{z} = require 'zorium'
RxObservable = require('rxjs/Observable').Observable

$appBar = require '../../components/app_bar'
$buttonMenu = require '../../components/button_menu'
$notifications = require '../../components/notifications'
config = require '../../config'
colors = require '../../colors'

if window?
  require './index.styl'

module.exports = $notificationsPage = ({model, router}) ->
  z '.p-notifications',
    z $appBar, {
      model
      title: model.l.get 'general.notifications'
      style: 'primary'
      $topLeftButton:
        z $buttonMenu, {model, router, color: colors.$header500Icon}
    }
    z $notifications, {model, router}
