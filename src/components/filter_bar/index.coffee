{z, classKebab, useRef, useMemo, useStream} = require 'zorium'
RxBehaviorSubject = require('rxjs/BehaviorSubject').BehaviorSubject
RxObservable = require('rxjs/Observable').Observable
require 'rxjs/add/observable/of'
_defaults = require 'lodash/defaults'
_map = require 'lodash/map'
_orderBy = require 'lodash/orderBy'

$filterPositionedOverlay = require '../filter_positioned_overlay'
$filterSheet = require '../filter_sheet'
colors = require '../../colors'

if window?
  require './index.styl'


module.exports = FilterBar = ({model, filtersStream}) ->
  {filterRefsCache, visibleFilterContentsStream} = useMemo ->
    {
      filterRefsCache: {}
      visibleFilterContentsStream: new RxBehaviorSubject []
    }
  , []

  {visibleFilterContents, filters} = useStream ->
    visibleFilterContents: visibleFilterContentsStream
    filters: filtersStream.map (filters) ->
      filters = _map filters, (filter) ->
        filterRefsCache[filter.id] ?= useRef()
        filter
      _orderBy filters, (({value}) -> value?), 'desc'

  showFilterContent = ({filter, $$filterRef}) =>
    visibleFilterContentsStream.next [{filter, $$filterRef}]

  z '.z-filter-bar',
    z '.filters',
      _map filters, (filter, i) =>
        if filter.name
          z '.filter', {
            ref: filterRefsCache[filter.id]
            key: filter.id
            className: classKebab {
              hasMore: not filter.isBoolean
              hasValue: filter.value? and filter.value isnt ''
            }
            onclick: (e) =>
              ga? 'send', 'event', 'map', 'filterClick', filter.field
              if filter.isBoolean
                filter.valueStreams.next(
                  RxObservable.of (not filter.value) or null
                )
              else
                console.log filter.id, filterRefsCache[filter.id]
                showFilterContent {
                  filter, $$filterRef: filterRefsCache[filter.id]
                }
          }, filter.name

    _map visibleFilterContents, ({filter, $$filterRef}) ->
      z $filterPositionedOverlay, {
        model, filter, $$targetRef: $$filterRef
        onClose: ->
          visibleFilterContentsStream.next []
      }
