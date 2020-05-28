{z, useContext} = require 'zorium'

$appBar = require 'frontend-shared/components/app_bar'
$buttonMenu = require 'frontend-shared/components/button_menu'
$button = require 'frontend-shared/components/button'

colors = require '../../colors'
context = require '../../context'
config = require '../../config'

module.exports = $404Page = (props) ->
  {requestsStream, serverData, entity} = props
  {lang, router} = useContext context

  z '.p-404',
    z $appBar, {
      title: lang.get '404Page.text'
      $topLeftButton: z $buttonMenu, {color: colors.$header500Icon}
    }
    z '.content', {
      style:
        padding: '16px'
    },
      lang.get '404Page.text'
      z 'br'
      '(╯°□°)╯︵ ┻━┻'
      z $button,
        text: lang.get 'general.back'
        onclick: ->
          router.goPath '/'
