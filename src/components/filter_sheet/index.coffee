{z, useMemo, useStream} = require 'zorium'
RxBehaviorSubject = require('rxjs/BehaviorSubject').BehaviorSubject
RxObservable = require('rxjs/Observable').Observable
require 'rxjs/add/observable/of'

$sheet = require '../sheet'
$filterContent = require '../filter_content'
$button = require '../button'
colors = require '../../colors'
config = require '../../config'

if window?
  require './index.styl'

module.exports = $filterSheet = ({model, filter, id}) ->
  {resetStream} = useMemo ->
    {resetStream: new RxBehaviorSubject null}
  , []

  {value, resetValue} = useStream ->
    # HACK: do to keep filter value up-to-date when resetting
    value: filter.valueStreams.switch().do (updatedValue) ->
      filter.value = updatedValue
    resetValue: resetStream

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
                  setTimeout ->
                    resetStream.next Math.random()
                  , 0
          z $filterContent, {
            model, filter, resetValue
          }
