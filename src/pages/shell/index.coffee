{z, useContext, useStream} = require 'zorium'

$appBar = require 'frontend-shared/components/app_bar'
$buttonMenu = require 'frontend-shared/components/button_menu'
$spinner = require 'frontend-shared/components/spinner'

colors = require '../../colors'
context = require '../../context'
config = require '../../config'

if window?
  require './index.styl'

# generic page that gets loaded from cache for any page w/o a specific shell
module.exports = $shellPage = ({requestsStream}) ->
  {model} = useContext context
  # subscribe so they're in exoid cache
  {} = useStream ->
    me: model.user.getMe()

  z '.p-shell',
    z $appBar, {
      title: ''
      style: 'primary'
      $topLeftButton:
        z $buttonMenu, {color: colors.$header500Icon}
    }
    z '.spinner',
      $spinner
