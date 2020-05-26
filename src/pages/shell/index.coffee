{z, useContext, useStream} = require 'zorium'

$appBar = require '../../components/app_bar'
$buttonMenu = require '../../components/button_menu'
$spinner = require '../../components/spinner'
colors = require '../../colors'
context = require '../../context'
config = require '../../config'

if window?
  require './index.styl'

# generic page that gets loaded from cache for any page w/o a specific shell
module.exports = $shellPage = ({requestsStream, entitySteam}) ->
  {model} = useContext context
  # subscribe so they're in exoid cache
  {} = useStream ->
    me: model.user.getMe()
    entity: entityStream

  z '.p-shell',
    z $appBar, {
      title: ''
      style: 'primary'
      $topLeftButton:
        z $buttonMenu, {color: colors.$header500Icon}
    }
    z '.spinner',
      $spinner
