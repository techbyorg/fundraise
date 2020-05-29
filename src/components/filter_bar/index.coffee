import {z, classKebab, useRef, useMemo, useStream} from 'zorium'
import * as _ from 'lodash-es'
RxBehaviorSubject = require('rxjs/BehaviorSubject').BehaviorSubject
RxObservable = require('rxjs/Observable').Observable
require 'rxjs/add/observable/of'

import Environment from 'frontend-shared/services/environment'

import $filterContentPositionedOverlay from '../filter_content_positioned_overlay'
import $filterContentSheet from '../filter_content_sheet'
import colors from '../../colors'

if window?
  require './index.styl'


export default $filterBar = ({filtersStream}) ->
  {filterRefsCache, visibleFilterContentsStream} = useMemo ->
    {
      filterRefsCache: {}
      visibleFilterContentsStream: new RxBehaviorSubject []
    }
  , []

  {visibleFilterContents, filters} = useStream ->
    visibleFilterContents: visibleFilterContentsStream
    filters: filtersStream.map (filters) ->
      filters = _.map filters, (filter) ->
        filterRefsCache[filter.id] ?= useRef()
        filter
      _.orderBy filters, (({value}) -> value?), 'desc'

  toggleFilterContent = ({filter, $$filterRef}) =>
    isVisible = _.find visibleFilterContents, (visibleFilter) ->
      visibleFilter.filter.id is filter.id
    console.log 'toggle', isVisible
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
                     then $filterContentSheet \
                     else $filterContentPositionedOverlay

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
                  RxObservable.of (not filter.value) or null
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
