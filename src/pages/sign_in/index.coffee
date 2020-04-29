{z} = require 'zorium'
RxBehaviorSubject = require('rxjs/BehaviorSubject').BehaviorSubject
_map = require 'lodash/map'

$appBar = require '../../components/app_bar'
$signIn = require '../../components/sign_in'
config = require '../../config'

if window?
  require './index.styl'

module.exports = SignInPage = ({model, router, entityStream}) ->
  z '.p-sign-in',
    z $appBar, {
      model
      hasLogo: true
      # $topLeftButton: z $buttonBack, {color: colors.$header500Icon}
    }
    z $signIn, {model, router}
