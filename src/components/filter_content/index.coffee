import {z, classKebab, useContext, useMemo, useStream} from 'zorium'
import * as _ from 'lodash-es'
import * as Rx from 'rxjs'
import * as rx from 'rxjs/operators'

import $checkbox from 'frontend-shared/components/checkbox'
import $dropdown from 'frontend-shared/components/dropdown'
import $icon from 'frontend-shared/components/icon'
import $input from 'frontend-shared/components/input'
import $inputRange from 'frontend-shared/components/input_range'
import {
  chevronRightIconPath, chevronLeftIconPath
} from 'frontend-shared/components/icon/paths'

import colors from '../../colors'
import context from '../../context'
import config from '../../config'

if window?
  require './index.styl'

export default $filterContent = (props) ->
  {filter, valueStreams, filterValue, isGrouped, overlayAnchor, $$parentRef} = props
  {lang} = useContext context

  filterValueStr = JSON.stringify filterValue # for "deep" compare

  {custom} = useMemo ->
    switch filter.type
      when 'gtlt'
        operatorStream = new Rx.BehaviorSubject filterValue?.operator
        valueStream = new Rx.BehaviorSubject filterValue?.value or ''
        valueStreams.next Rx.combineLatest(
          operatorStream, valueStream, (vals...) -> vals
        ).pipe rx.map ([operator, value]) ->
          if operator or value
            {operator, value}

        {custom: {operatorStream, valueStream}}

      when 'minMax'
        minStream = new Rx.BehaviorSubject filterValue?.min or filter.minOptions[0].value
        maxStream = new Rx.BehaviorSubject filterValue?.max or filter.maxOptions[0].value
        valueStreams.next Rx.combineLatest(
          minStream, maxStream, (vals...) -> vals
        ).pipe rx.map ([min, max]) ->
          min = min and parseInt min
          max = max and parseInt max
          if min or max
            {min, max}

        {custom: {minStream, maxStream}}

      when 'listBooleanAnd', 'listBooleanOr', 'fieldList', 'booleanArraySubTypes'
        list = filter.items
        items = _.map list, ({label}, key) =>
          valueStream = new Rx.BehaviorSubject(
            filterValue?[key]
          )
          {
            valueStream, label, key
          }

        valueStreams.next Rx.combineLatest(
          _.map items, 'valueStream'
          (vals...) -> vals
        ).pipe rx.map (vals) ->
          unless _.isEmpty _.filter(vals)
            _.zipObject _.map(list, 'key'), vals

        {
          custom: {items}
        }

      when 'listAnd', 'listOr'
        list = filter.items

        checkboxes =  _.map list, ({label}, key) =>
          valueStream = new Rx.BehaviorSubject(
            filterValue?[key]
          )
          {valueStream, label}

        valueStreams.next Rx.combineLatest(
          _.map checkboxes, 'valueStream'
          (vals...) -> vals
        ).pipe rx.map (vals) ->
          unless _.isEmpty _.filter(vals)
            _.zipObject _.keys(list), vals

        {
          custom: {checkboxes}
        }
      else
        {}
  , [filterValueStr]

  switch filter.type
    when 'maxInt', 'minInt'
      value = filterValue?.value or filterValue
      $content =
        z '.content',
          unless isGrouped
            z '.info', lang.get "filterSheet.#{filter.field}Label"
          z '.info', lang.get "levelText.#{filter.field}#{value}"
          z $inputRange, {
            valueStreams, minValue: 1, maxValue: 5
          }
    when 'maxIntCustom', 'minIntCustom'
      $content =
        z '.content',
          z '.label',
            z '.text', lang.get "filterSheet.#{filter.key}"
            z '.small-input',
              filter.inputPrefix
              z $input, {
                valueStreams
                type: 'number'
                height: '30px'
              }
              filter.inputPostfix
    when 'listBooleanAnd', 'listBooleanOr', 'fieldList', 'booleanArraySubTypes'
      $content =
        z '.content.tappable',
          z '.tap-items', {
            className: classKebab {isFullWidth: filter.field is 'subType'}
          },
            _.map custom.items, ({valueStream, label, key, $icon}) =>
              isSelected = valueStream.getValue()
              z '.tap-item', {
                className: classKebab {
                  isSelected
                }
                onclick: ->
                  valueStream.next not isSelected
              },
                label or "FIXME: #{filter.id}"
    when 'listAnd', 'listOr', 'fieldList'
      $content =
        z '.content',
          _.map custom.checkboxes, ({valueStream, label}) ->
            z 'label.label',
              z '.checkbox',
                z $checkbox, {valueStream}
              z '.text', label or 'fixme'

    when 'booleanArray'
      $content =
        z '.content',
          z 'label.label',
            z '.checkbox',
              z $checkbox, {valueStreams}
            z '.text', filter.title or filter.name

    when 'minMax'
      $content =
        z '.content.min-max',
          z '.flex',
            z '.block',
              z $dropdown, {
                $$parentRef
                valueStream: custom.minStream
                options: filter.minOptions
                anchor: overlayAnchor
              }
            z '.dash', '-'
            z '.block',
              z $dropdown, {
                $$parentRef
                valueStream: custom.maxStream
                options: filter.maxOptions
                anchor: overlayAnchor
              }
    when 'gtlt'
      operator = filterValue?.operator
      $content =
        z '.content.gtlt',
          z '.metric.label',
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
                  icon: chevronRightIconPath
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
                  icon: chevronLeftIconPath
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

  z '.z-filter-content', {
    # we want all inputs, etc... to restart w/ new valueStreams
    key: "#{filterValueStr}"
  },
    $content
