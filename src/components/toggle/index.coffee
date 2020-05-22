{z, classKebab, useMemo, useStream} = require 'zorium'
RxReplaySubject = require('rxjs/ReplaySubject').ReplaySubject
RxObservable = require('rxjs/Observable').Observable
require 'rxjs/add/observable/of'

if window?
  require './index.styl'

module.exports = $togle = (props) ->
  {isSelectedStreams, isSelectedStreams, model, onToggle, withText} = props

  {isSelectedStreams} = useMemo ->
    unless isSelectedStreams
      isSelectedStreams = new RxReplaySubject 1
      isSelectedStreams ?= RxObservable.of ''
      isSelectedStreams.next isSelectedStream
    {
      isSelectedStreams
    }
  , []

  {isSelected} = useStream ->
    isSelected: isSelectedStreams.switch()

  toggle = ({onToggle} = {}) ->
    if isSelected
      isSelected.next not isSelected
    else
      isSelectedStreams.next RxObservable.of not isSelected
    onToggle? not isSelected


  z '.z-toggle', {
    className: classKebab {isSelected, withText}
    onclick: -> toggle {onToggle}
  },
    z '.track',
      if withText and isSelected
        model.l.get 'general.yes'
      else if withText
        model.l.get 'general.no'

    z '.knob'
