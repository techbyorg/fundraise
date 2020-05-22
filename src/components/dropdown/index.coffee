{z, classKebab, useMemo, useStream} = require 'zorium'
_map = require 'lodash/map'
_find = require 'lodash/find'
RxBehaviorSubject = require('rxjs/BehaviorSubject').BehaviorSubject
RxReplaySubject = require('rxjs/ReplaySubject').ReplaySubject
RxObservable = require('rxjs/Observable').Observable
require 'rxjs/add/observable/of'

$icon = require '../icon'
colors = require '../../colors'

if window?
  require './index.styl'

module.exports = Dropdown = (props) ->
  {model, valueStreams, valueStream, errorStream, options,
    isDisabled = false} = props

  {valueStream, selectedOptionStream, isOpenStream} = useMemo ->
    {
      valueStream: valueStream or new RxReplaySubject 1
      selectedOptionStream: valueStream
      isOpenStream: new RxBehaviorSubject false
    }
  , []

  {value, selectedOption, isOpen, options} = useStream ->
    _valueStream = valueStreams?.switch() or valueStream
    value: _valueStream
    selectedOption: _valueStream.map (value) ->
      _find options, {value}
    error: errorStream
    isOpen: isOpenStream
    options: options

  setValue = (value) ->
    if valueStreams
      valueStreams.next RxObservable.of value
    else
      valueStream.next value

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
        selectedOption?.text
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
            setValue option.value
            toggle()
        },
          z '.text',
            option.text
    if error?
      z '.error', error
