import {z, classKebab, useRef, useMemo, useStream} from 'zorium'
import * as _ from 'lodash-es'
import * as Rx from 'rxjs'
import * as rx from 'rxjs/operators'

import Environment from 'frontend-shared/services/environment'

import $filterPositionedOverlay from '../filter_positioned_overlay'
import $filterSheet from '../filter_sheet'
import colors from '../../colors'

if window?
  require './index.styl'


export default $filterBar = ({filtersStream}) ->
  {filterRefsCache, visibleFilterContentsStream} = useMemo ->
    {
      filterRefsCache: {}
      visibleFilterContentsStream: new Rx.BehaviorSubject []
    }
  , []

  {visibleFilterContents, filters} = useStream ->
    visibleFilterContents: visibleFilterContentsStream
    filters: filtersStream.pipe rx.map (filters) ->
      filters = _.map filters, (filter) ->
        filterRefsCache[filter.id] ?= useRef()
        filter
      _.orderBy filters, (({value}) -> value?), 'desc'

  toggleFilterContent = ({filter, $$filterRef}) =>
    isVisible = _.find visibleFilterContents, (visibleFilter) ->
      visibleFilter.filter.id is filter.id
    if isVisible
      visibleFilterContentsStream.next(
        _.filter visibleFilterContents, (visibleFilter) ->
          visibleFilter.filter.id isnt filter.id
      )
    else
      visibleFilterContentsStream.next visibleFilterContents.concat [
        {filter, $$filterRef}
      ]


  isMobile = Environment.isMobile()
  $filterContentEl = if isMobile \
                     then $filterSheet \
                     else $filterPositionedOverlay

  z '.z-filter-bar',
    z '.filters',
      _.map filters, (filter, i) =>
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
                  Rx.of (not filter.value) or null
                )
              else
                toggleFilterContent {
                  filter, $$filterRef: filterRefsCache[filter.id]
                }
          }, filter.name

    _.map visibleFilterContents, ({filter, $$filterRef}) ->
      id = filter.id
      z $filterContentEl, {
        filter, $$targetRef: $$filterRef
        onClose: ->
          visibleFilterContents = visibleFilterContentsStream.getValue()
          newFilterContents = _.filter visibleFilterContents, ({filter}) ->
            id isnt filter.id
          visibleFilterContentsStream.next newFilterContents
      }
