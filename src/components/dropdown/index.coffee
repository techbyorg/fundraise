z = require 'zorium'
_map = require 'lodash/map'
RxReplaySubject = require('rxjs/ReplaySubject').ReplaySubject
RxObservable = require('rxjs/Observable').Observable
require 'rxjs/add/observable/of'

Icon = require '../icon'
colors = require '../../colors'

if window?
  require './index.styl'

module.exports = class Dropdown
  constructor: ({@model, @valueStreams, @error, options} = {}) ->
    @valueStreams ?= new RxReplaySubject 1
    # @valueStreams.next RxObservable.of null

    @$dropdownArrow = new Icon()

    @state = z.state {
      value: @valueStreams?.switch()
      isOpen: false
      options: options
    }

  toggle: =>
    {isOpen} = @state.getValue()
    @state.set isOpen: not isOpen

  render: ({isDisabled, currentText}) =>
    {value, isOpen, options} = @state.getValue()

    isDisabled ?= false

    console.log 'val', value, options

    z '.z-dropdown', {
      className: z.classKebab {
        hasValue: value isnt ''
        isDisabled
        isOpen
        isError: error?
      }
    },
      z '.wrapper', {
        onclick: =>
          @toggle()

      }
      z '.current', {
        onclick: @toggle
      },
        z '.text',
          currentText
        z '.arrow',
          z @$dropdownArrow,
            icon: 'chevron-down'
            isTouchTarget: false
            color: colors.$secondaryMainText
      z '.options',
        _map options, (option) =>
          z 'label.option', {
            className: z.classKebab {isSelected: value is option.value}
            onclick: =>
              @valueStreams.next RxObservable.of option.value
              @toggle()
          },
            z '.text',
              option.text
      if error?
        z '.error', error
