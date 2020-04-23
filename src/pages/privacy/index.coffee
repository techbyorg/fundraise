{z} = require 'zorium'

$appBar = require '../../components/app_bar'
$buttonBack = require '../../components/button_back'
$privacy = require '../../components/privacy'
colors = require '../../colors'

if window?
  require './index.styl'

module.exports = PrivacyPage = ({model, router}) ->
  z '.p-privacy',
    z $appBar, {
      model
      title: model.l.get 'privacyPage.title'
      $topLeftButton: z $buttonBack, {
        model, router, color: colors.$header500Icon
      }
    }
    z $privacy, {model, router}
