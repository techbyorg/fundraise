z = require 'zorium'

AppBar = require '../../components/app_bar'
SignIn = require '../../components/sign_in'
config = require '../../config'

if window?
  require './index.styl'

module.exports = class SignInPage
  hideDrawer: true
  allowGuests: true

  constructor: ({@model, requests, @router, serverData, entity}) ->
    @$appBar = new AppBar {@model}
    @$signIn = new SignIn {@model, @router, entity}

  render: =>
    z '.p-sign-in',
      z @$appBar, {
        hasLogo: true
        # $topLeftButton: z @$buttonBack, {color: colors.$header500Icon}
      }
      z @$signIn
