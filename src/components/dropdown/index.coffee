{z, classKebab, useMemo, useStream} = require 'zorium'
_map = require 'lodash/map'
RxBehaviorSubject = require('rxjs/BehaviorSubject').BehaviorSubject
RxReplaySubject = require('rxjs/ReplaySubject').ReplaySubject
RxObservable = require('rxjs/Observable').Observable
require 'rxjs/add/observable/of'

$icon = require '../icon'
colors = require '../../colors'

if window?
  require './index.styl'

module.exports = Dropdown = (props) ->
  {model, valueStreams, errorStream, options, currentText,
    isDisabled = false} = props

  {valueStreams, isOpenStream} = useMemo ->
    {
      valueStreams: valueStreams or new RxReplaySubject 1
      isOpenStream: new RxBehaviorSubject false
    }
  , []
  # valueStreams.next RxObservable.of null

  {value, isOpen, options} = useStream ->
    value: valueStreams?.switch()
    error: errorStream
    isOpen: isOpenStream
    options: options

  toggle = ->
    isOpenStream.next not isOpen

  z '.z-dropdown', {
    className: classKebab {
      hasValue: value isnt ''
      isDisabled
      isOpen
      isError: error?
    }
  },
    z '.wrapper', {
      onclick: ->
        toggle()

    }
    z '.current', {
      onclick: toggle
    },
      z '.text',
        currentText
      z '.arrow',
        z $icon,
          icon: 'chevron-down'
          isTouchTarget: false
          color: colors.$secondaryMainText
    z '.options',
      _map options, (option) ->
        z 'label.option', {
          className: classKebab {isSelected: value is option.value}
          onclick: ->
            valueStreams.next RxObservable.of option.value
            toggle()
        },
          z '.text',
            option.text
    if error?
      z '.error', error
