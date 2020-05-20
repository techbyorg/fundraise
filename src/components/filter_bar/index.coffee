{z, classKebab, useStream} = require 'zorium'
RxObservable = require('rxjs/Observable').Observable
require 'rxjs/add/observable/of'
_map = require 'lodash/map'
_orderBy = require 'lodash/orderBy'

# $filterSheet = require '../filter_sheet'
$filterContent = require '../filter_content'
colors = require '../../colors'

if window?
  require './index.styl'


module.exports = FilterBar = ({model, filtersStream}) ->
  {filters} = useStream ->
    filters: filtersStream.map (filters) ->
      _orderBy filters, (({value}) -> value?), 'desc'

  console.log 'ff', filters

  showFilterSheet = (filter) =>
    id = Date.now()
    model.overlay.open (z $filterContent, {
      model, filter, id
    }), {id}

  z '.z-filter-bar',
    z '.bar',
      z '.filters',
        _map filters, (filter) =>
          console.log 'map', filter
          if filter.name
            z '.filter', {
              className: classKebab {
                hasMore: not filter.isBoolean
                hasValue: filter.value? and filter.value isnt ''
              }
              onclick: =>
                ga? 'send', 'event', 'map', 'filterClick', filter.field
                if filter.isBoolean
                  filter.valueStreams.next(
                    RxObservable.of (not filter.value) or null
                  )
                else
                  showFilterSheet filter
            }, filter.name
