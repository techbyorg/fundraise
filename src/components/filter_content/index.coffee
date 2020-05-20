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
Icon = require '../icon'
PrimaryInput = require '../primary_input'
Input = require '../input'
InputRange = require '../input_range'
colors = require '../../colors'
config = require '../../config'

if window?
  require './index.styl'

module.exports = FilterContent = ({model, filter, isGrouped}) ->
  {custom} = useMemo ->
    switch filter.type
      when 'gtlt'
        operatorStream = new RxBehaviorSubject filterValue?.operator
        valueStream = new RxBehaviorSubject filterValue?.value or ''
        $input = new Input {value: valueStream}
        filter.valueStreams.next RxObservable.combineLatest(
          operatorStream, valueStream, (vals...) -> vals
        ).map ([operator, value]) ->
          if operator or value
            {operator, value}

        {custom: {operatorStream, valueStream}}

      when 'iconListBooleanAnd', 'listBooleanAnd', 'listBooleanOr', 'fieldList', 'booleanArraySubTypes'
        list = filter.items
        items = _map list, ({key, label}) =>
          valueStream = new RxBehaviorSubject(
            filterValue?[key]
          )
          {
            valueStream, label, key
            $icon: if filter.type is 'iconListBooleanAnd'
              new Icon()
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
            filterValue?[key]
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

  , []

  {filterValue} = useStream ->
    filterValue: filter.valueStreams.switch()

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
    when 'iconListBooleanAnd', 'listBooleanAnd', 'listBooleanOr', 'fieldList', 'booleanArraySubTypes'
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
                  hasIcon: filter.type is 'iconListBooleanAnd'
                }
                onclick: ->
                  valueStream.next not isSelected
              },
                if filter.type is 'iconListBooleanAnd'
                  z '.icon',
                    z $icon,
                      icon: config.FEATURES_ICONS[key] or _kebabCase key
                      isTouchTarget: false
                      size: '20px'
                      color: if isSelected \
                             then colors.$secondary700 \
                             else colors.$bgText38

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
    when 'gtlt'
      operator = filterValue?.operator
      $content =
        z '.content',
          z '.metric.checkbox-label',
            z '.text', model.l.get "filterSheet.elevation"
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
