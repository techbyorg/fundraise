{z, useContext, useMemo, useEffect, useRef, useStream} = require 'zorium'
RxBehaviorSubject = require('rxjs/BehaviorSubject').BehaviorSubject
RxObservable = require('rxjs/Observable').Observable
require 'rxjs/add/observable/of'

$dialog = require '../dialog'
$filterContent = require '../filter_content'
$button = require '../button'
colors = require '../../colors'
context = require '../../context'
config = require '../../config'

if window?
  require './index.styl'

module.exports = $filterContentDialog = ({filter, onClose}) ->
  {lang} = useContext context

  {resetStream} = useMemo ->
    {resetStream: new RxBehaviorSubject null}
  , []

  {value, resetValue} = useStream ->
    # HACK: do to keep filter value up-to-date when resetting
    value: filter.valueStreams.switch().do (updatedValue) ->
      filter.value = updatedValue
    resetValue: resetStream

  z '.z-filter-content-dialog',
    z $dialog,
      onClose: onClose
      $content:
        z '.z-filter-content-dialog_content',
          z '.content',
            z $filterContent, {
              filter, resetValue
            }
          if value
            z '.actions',
              z '.reset',
                if value
                  z $button,
                    text: lang.get 'general.reset'
                    onclick: =>
                      filter.valueStreams.next RxObservable.of null
                      setTimeout ->
                        resetStream.next Math.random()
                      , 0
