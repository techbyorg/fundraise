{z} = require 'zorium'

config = require '../../config'
$appBar = require '../../components/app_bar'
$buttonMenu = require '../../components/button_menu'
$button = require '../../components/button'
colors = require '../../colors'

module.exports = $404Page = (props) ->
  {model, router, requests, serverData, entity} = props

  z '.p-404',
    z $appBar, {
      model
      title: model.l.get '404Page.text'
      $topLeftButton: z $buttonMenu, {model, color: colors.$header500Icon}
    }
    z '.content', {
      style:
        padding: '16px'
    },
      model.l.get '404Page.text'
      z 'br'
      '(╯°□°)╯︵ ┻━┻'
      z $button,
        text: model.l.get 'general.back'
        onclick: ->
          router.goPath '/'
