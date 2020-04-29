{z} = require 'zorium'

$appBar = require '../../components/app_bar'
$buttonMenu = require '../../components/button_menu'
$editor = require '../../components/editor'
colors = require '../../colors'

if window?
  require './index.styl'

module.exports = EditorPage = ({model, router}) ->
  console.log 'EDITOR PAGE'
  z '.p-editor',
    z $appBar, {
      model
      title: model.l.get 'editorPage.title'
      $topLeftButton: z $buttonMenu, {
        model, router, color: colors.$header500Icon
      }
    }
    z $editor, {model, router}
