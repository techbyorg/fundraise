z = require 'zorium'
RxObservable = require('rxjs/Observable').Observable

AppBar = require '../../components/app_bar'
ButtonMenu = require '../../components/button_menu'
Icon = require '../../components/icon'
Notifications = require '../../components/notifications'
config = require '../../config'
colors = require '../../colors'

if window?
  require './index.styl'

module.exports = class NotificationsPage
  constructor: ({@model, @router}) ->
    @$appBar = new AppBar {@model}
    @$buttonMenu = new ButtonMenu {@model, @router}
    @$settingsIcon = new Icon()
    @$notifications = new Notifications {@model, @router}

  getMeta: ->
    {
      title: 'Notifications'
    }

  render: =>
    z '.p-notifications',
      z @$appBar, {
        title: @model.l.get 'general.notifications'
        style: 'primary'
        $topLeftButton: z @$buttonMenu, {color: colors.$header500Icon}
      }
      @$notifications
