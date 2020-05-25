{z, classKebab, useMemo, useStream} = require 'zorium'
RxBehaviorSubject = require('rxjs/BehaviorSubject').BehaviorSubject
RxObservable = require('rxjs/Observable').Observable
require 'rxjs/add/observable/combineLatest'
require 'rxjs/add/observable/of'
_map = require 'lodash/map'
_filter = require 'lodash/filter'
_isEmpty = require 'lodash/isEmpty'
_range = require 'lodash/range'
_kebabCase = require 'lodash/kebabCase'
_startCase = require 'lodash/startCase'
_zipObject = require 'lodash/zipObject'

$checkbox = require '../checkbox'
$dropdown = require '../dropdown'
$icon = require '../icon'
$input = require '../input'
$inputRange = require '../input_range'
colors = require '../../colors'
config = require '../../config'

if window?
  require './index.styl'

module.exports = $filterContent = (props) ->
  {model, filter, resetValue, isGrouped, overlayAnchor, $$parentRef} = props

  {custom} = useMemo ->
    switch filter.type
      when 'gtlt'
        operatorStream = new RxBehaviorSubject filter.value?.operator
        valueStream = new RxBehaviorSubject filter.value?.value or ''
        filter.valueStreams.next RxObservable.combineLatest(
          operatorStream, valueStream, (vals...) -> vals
        ).map ([operator, value]) ->
          if operator or value
            {operator, value}

        {custom: {operatorStream, valueStream}}

      when 'minMax'
        minStream = new RxBehaviorSubject filter.value?.min or filter.minOptions[0].value
        maxStream = new RxBehaviorSubject filter.value?.max or filter.maxOptions[0].value
        filter.valueStreams.next RxObservable.combineLatest(
          minStream, maxStream, (vals...) -> vals
        ).map ([min, max]) ->
          if min? or max?
            {min, max}

        {custom: {minStream, maxStream}}

      when 'listBooleanAnd', 'listBooleanOr', 'fieldList', 'booleanArraySubTypes'
        list = filter.items
        items = _map list, ({key, label}) =>
          valueStream = new RxBehaviorSubject(
            filter.value?[key]
          )
          {
            valueStream, label, key
          }

        filter.valueStreams.next RxObservable.combineLatest(
          _map items, 'valueStream'
          (vals...) -> vals
        ).map (vals) ->
          unless _isEmpty _filter(vals)
            _zipObject _map(list, 'key'), vals

        {
          custom: {items}
        }

      when 'list'
        list = filter.items

        checkboxes =  _map list, ({key, label}) =>
          valueStream = new RxBehaviorSubject(
            filter.value?[key]
          )
          {valueStream, label}

        filter.valueStreams.next RxObservable.combineLatest(
          _map checkboxes, 'valueStream'
          (vals...) -> vals
        ).map (vals) ->
          unless _isEmpty _filter(vals)
            _zipObject _map(list, 'key'), vals

        {
          custom: {checkboxes}
        }
  , [resetValue]

  switch filter.type
    when 'maxInt', 'minInt'
      value = filterValue?.value or filterValue
      $content =
        z '.content',
          if isGrouped
            z '.title', filter.title or filter.name

          unless isGrouped
            z '.info', model.l.get "filterSheet.#{filter.field}Label"
          z '.info', model.l.get "levelText.#{filter.field}#{value}"
          z $inputRange, {
            model, valueStreams: filter.valueStreams, minValue: 1, maxValue: 5
          }
    when 'maxIntCustom', 'minIntCustom'
      $content =
        z '.content',
          z '.checkbox-label',
            z '.text', model.l.get "filterSheet.#{filter.key}"
            z '.small-input',
              filter.inputPrefix
              z $input, {
                valueStreams: filter.valueStreams
                type: 'number'
                height: '30px'
              }
              filter.inputPostfix
    when 'listBooleanAnd', 'listBooleanOr', 'fieldList', 'booleanArraySubTypes'
      $content =
        z '.content',
          if isGrouped
            z '.title', filter.title or filter.name

          z '.tap-items', {
            className: classKebab {isFullWidth: filter.field is 'subType'}
          },
            _map custom.items, ({valueStream, label, key, $icon}) =>
              isSelected = valueStream.getValue()
              z '.tap-item', {
                className: classKebab {
                  isSelected
                }
                onclick: ->
                  valueStream.next not isSelected
              },
                label or 'fixme'
    when 'list', 'fieldList'
      # $title = filter?.name
      $content =
        z '.content',
          _map custom.checkboxes, ({valueStream, label}) ->
            z 'label.checkbox-label',
              z '.text', label or 'fixme'
              z '.input',
                z $checkbox, {valueStream}
    when 'minMax'
      $content =
        z '.content',
          z '.flex',
            z '.block',
              z $dropdown, {
                model
                $$parentRef
                valueStream: custom.minStream
                options: filter.minOptions
                anchor: overlayAnchor
              }
            z '.dash', '-'
            z '.block',
              z $dropdown, {
                model
                $$parentRef
                valueStream: custom.maxStream
                options: filter.maxOptions
                anchor: overlayAnchor
              }
    when 'gtlt'
      operator = filterValue?.operator
      $content =
        z '.content',
          z '.metric.checkbox-label',
            z '.text', 'gtlt' # FIXME
            z '.operators',
              z '.operator', {
                className: classKebab {
                  isSelected: operator is 'gt'
                }
                onclick: =>
                  custom.operatorStream.next 'gt'
              },
                z $icon,
                  icon: 'chevron-right'
                  isTouchTarget: false
                  size: '20px'
                  color: if operator is 'gt' \
                         then colors.$secondaryMainText \
                         else colors.$bgText38
              z '.operator', {
                className: classKebab {
                  isSelected: operator is 'lt'
                }
                onclick: =>
                  custom.operatorStream.next 'lt'
              },
                z $icon,
                  icon: 'chevron-left'
                  isTouchTarget: false
                  size: '20px'
                  color: if operator is 'lt' \
                         then colors.$secondaryMainText \
                         else colors.$bgText38
            z '.operator-input-wide',
              z $input, {
                valueStream: custom.valueStream
                type: 'number'
                height: '24px'
              }

    when 'booleanArray'
      $content =
        z '.content',
          z 'label.checkbox-label',
            z '.text', filter.title or filter.name
            z '.input',
              z $checkbox, {valueStreams: filter.valueStreams}

  z '.z-filter-content',
    unless isGrouped
      z '.title', filter.title or filter.name
    z '.content',
      if not isGrouped and filter.field in [
        'maxLength', 'crowds', 'roadDifficulty'
        'shade', 'safety', 'noise', 'features'
      ]
        z '.warning',
          model.l.get 'filterSheet.userInputWarning'
      $content
