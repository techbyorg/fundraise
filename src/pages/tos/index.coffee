{z} = require 'zorium'

$appBar = require '../../components/app_bar'
$buttonBack = require '../../components/button_back'
$privacy = require '../../components/privacy'
colors = require '../../colors'

if window?
  require './index.styl'

module.exports = TosPage = ({model, router}) ->
  z '.p-tos',
    z $appBar, {
      model
      title: model.l.get 'tosPage.title'
      $topLeftButton: z $buttonBack, {
        model, router, color: colors.$header500Icon
      }
    }
    z $tos, {model, router}
