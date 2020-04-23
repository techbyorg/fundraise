{z, useStream} = require 'zorium'

$appBar = require '../../components/app_bar'
$buttonMenu = require '../../components/button_menu'
$spinner = require '../../components/spinner'
config = require '../../config'
colors = require '../../colors'

if window?
  require './index.styl'

# generic page that gets loaded from cache for any page w/o a specific shell
module.exports = ShellPage = ({model, router, requests, entitySteam}) ->
  # subscribe so they're in exoid cache
  {} = useStream ->
    me: model.user.getMe()
    entity: entityStream

  z '.p-shell',
    z $appBar, {
      model
      title: ''
      style: 'primary'
      $topLeftButton:
        z $buttonMenu, {model, router, color: colors.$header500Icon}
    }
    z '.spinner',
      $spinner
