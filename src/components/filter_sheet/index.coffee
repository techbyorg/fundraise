{z, useStream} = require 'zorium'
RxObservable = require('rxjs/Observable').Observable
require 'rxjs/add/observable/of'

$sheet = require '../sheet'
$filterContent = require '../filter_content'
$button = require '../button'
colors = require '../../colors'
config = require '../../config'

if window?
  require './index.styl'

module.exports = FilterSheet = ({model, filter, id}) ->
  {value} = useStream ->
    value: filter.valueStreams.switch()

  z '.z-filter-sheet',
    z $sheet,
      model: model
      id: id
      isVanilla: true
      $content:
        z '.z-filter-sheet_sheet',
          z '.reset',
            if value
              z $button,
                text: model.l.get 'general.reset'
                onclick: =>
                  filter.valueStreams.next RxObservable.of null
                  $content.setup()
          z $filterContent, {model, filter}
