z = require 'zorium'

config = require '../../config'
AppBar = require '../../components/app_bar'
ButtonMenu = require '../../components/button_menu'
Button = require '../../components/button'
colors = require '../../colors'

module.exports = class FourOhFourPage
  allowGuests: true

  constructor: ({@model, @router, requests, serverData, entity}) ->
    @$appBar = new AppBar {@model}
    @$buttonMenu = new ButtonMenu {@model}
    @$homeButton = new Button()

  getMeta: ->
    meta:
      title: '404'
      description: 'Page not found'

  render: =>
    z '.p-404',
      z @$appBar, {
        title: @model.l.get '404Page.text'
        $topLeftButton: z @$buttonMenu, {color: colors.$header500Icon}
      }
      z '.content', {
        style:
          padding: '16px'
      },
        @model.l.get '404Page.text'
        z 'br'
        '(╯°□°)╯︵ ┻━┻'
        z @$homeButton,
          text: @model.l.get 'general.back'
          onclick: =>
            @router.goPath '/'
