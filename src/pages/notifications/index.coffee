{z, useContext} = require 'zorium'
RxObservable = require('rxjs/Observable').Observable

$appBar = require '../../components/app_bar'
$buttonMenu = require '../../components/button_menu'
$notifications = require '../../components/notifications'
config = require '../../config'
context = require '../../context'
colors = require '../../colors'

if window?
  require './index.styl'

module.exports = $notificationsPage = ->
  {lang} = useContext context

  z '.p-notifications',
    z $appBar, {
      title: lang.get 'general.notifications'
      style: 'primary'
      $topLeftButton:
        z $buttonMenu, {color: colors.$header500Icon}
    }
    z $notifications
