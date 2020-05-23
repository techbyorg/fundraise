{z, classKebab, useRef, useMemo, useStream} = require 'zorium'
RxBehaviorSubject = require('rxjs/BehaviorSubject').BehaviorSubject
RxObservable = require('rxjs/Observable').Observable
require 'rxjs/add/observable/of'
_defaults = require 'lodash/defaults'
_filter = require 'lodash/filter'
_map = require 'lodash/map'
_orderBy = require 'lodash/orderBy'
_uniqBy = require 'lodash/uniqBy'

$filterContentPositionedOverlay = require '../filter_content_positioned_overlay'
$filterContentSheet = require '../filter_content_sheet'
Environment = require '../../services/environment'
colors = require '../../colors'

if window?
  require './index.styl'


module.exports = $filterBar = ({model, filtersStream}) ->
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
    visibleFilterContentsStream.next _uniqBy visibleFilterContents.concat([
      {filter, $$filterRef}
    ]), ({filter}) -> filter.id

  isMobile = Environment.isMobile()
  $filterContentEl = if isMobile \
                     then $filterContentSheet \
                     else $filterContentPositionedOverlay

  console.log 'vis', visibleFilterContents

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
      id = filter.id
      z $filterContentEl, {
        model, filter, $$targetRef: $$filterRef
        onClose: ->
          visibleFilterContents = visibleFilterContentsStream.getValue()
          newFilterContents = _filter visibleFilterContents, ({filter}) ->
            id isnt filter.id
          visibleFilterContentsStream.next newFilterContents
      }
