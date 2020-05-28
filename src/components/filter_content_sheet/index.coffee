{z, useContext, useMemo, useStream} = require 'zorium'
RxBehaviorSubject = require('rxjs/BehaviorSubject').BehaviorSubject
RxReplaySubject = require('rxjs/ReplaySubject').ReplaySubject
RxObservable = require('rxjs/Observable').Observable
require 'rxjs/add/observable/of'

$sheet = require 'frontend-shared/components/sheet'
$button = require 'frontend-shared/components/button'

$filterContent = require '../filter_content'
colors = require '../../colors'
context = require '../../context'
config = require '../../config'

if window?
  require './index.styl'

module.exports = $filterContentSheet = ({id, filter, onClose}) ->
  {lang} = useContext context

  {valueStreams} = useMemo ->
    valueStreams = new RxReplaySubject 1
    valueStreams.next filter.valueStreams.switch()
    {
      valueStreams
    }
  , []

  {filterValue, hasValue} = useStream ->
    filterValue: filter.valueStreams.switch()
    hasValue: valueStreams.switch().map (value) -> Boolean value
              .distinctUntilChanged((a, b) -> a is b) # don't rerender a bunch

  z '.z-filter-content-sheet',
    key: filter.id
    z $sheet,
      id: filter.id
      onClose: onClose
      $content:
        z '.z-filter-content-sheet_sheet',
          z '.actions',
            z '.reset',
              if hasValue
                z $button,
                  text: lang.get 'general.reset'
                  onclick: ->
                    filter.valueStreams.next RxObservable.of null
                    valueStreams.next RxObservable.of null
            z '.save',
              z $button,
                text: lang.get 'general.save'
                isPrimary: true
                onclick: ->
                  filter.valueStreams.next valueStreams.switch()
                  onClose()
          z '.title',
            filter?.title or filter?.name
          z $filterContent, {
            filter, filterValue, valueStreams, overlayAnchor: 'bottom-left'
          }
