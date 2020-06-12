import { z, classKebab, useRef, useMemo, useStream } from 'zorium'
import * as _ from 'lodash-es'
import * as Rx from 'rxjs'
import * as rx from 'rxjs/operators'

import Environment from 'frontend-shared/services/environment'

import $filterPositionedOverlay from '../filter_positioned_overlay'
import $filterSheet from '../filter_sheet'

if (typeof window !== 'undefined' && window !== null) {
  require('./index.styl')
}

export default function $filterBar ({ filtersStream }) {
  const { filterRefsCache, visibleFilterContentsStream } = useMemo(() => {
    return {
      filterRefsCache: {},
      visibleFilterContentsStream: new Rx.BehaviorSubject([])
    }
  }, [])

  const { visibleFilterContents, filters } = useStream(() => ({
    visibleFilterContents: visibleFilterContentsStream,

    filters: filtersStream.pipe(rx.map((filters) => {
      filters = _.map(filters, function (filter) {
        if (filterRefsCache[filter.id] == null) { filterRefsCache[filter.id] = useRef() }
        return filter
      })
      return _.orderBy(filters, ({ value }) => value != null, 'desc')
    }))
  }))

  const toggleFilterContent = ({ filter, $$filterRef }) => {
    const isVisible = _.find(visibleFilterContents, (visibleFilter) =>
      visibleFilter.filter.id === filter.id
    )
    if (isVisible) {
      return visibleFilterContentsStream.next(
        _.filter(visibleFilterContents, visibleFilter =>
          visibleFilter.filter.id !== filter.id
        )
      )
    } else {
      return visibleFilterContentsStream.next(visibleFilterContents.concat([
        { filter, $$filterRef }
      ]))
    }
  }

  const isMobile = Environment.isMobile()
  const $filterContentEl = isMobile ? $filterSheet : $filterPositionedOverlay

  return z('.z-filter-bar', [
    z('.filters',
      _.map(filters, (filter, i) => {
        if (filter.name) {
          return z('.filter', {
            ref: filterRefsCache[filter.id],
            key: filter.id,
            className: classKebab({
              hasMore: !filter.isBoolean,
              hasValue: (filter.value != null) && (filter.value !== '')
            }),
            onclick: e => {
              globalThis?.window?.ga?.('send', 'event', 'map', 'filterClick', filter.field)
              if (filter.isBoolean) {
                return filter.valueStreams.next(
                  Rx.of((!filter.value) || null)
                )
              } else {
                return toggleFilterContent({
                  filter, $$filterRef: filterRefsCache[filter.id]
                })
              }
            }
          }, filter.name)
        }
      })
    ),

    _.map(visibleFilterContents, function ({ filter, $$filterRef }) {
      const { id } = filter
      return z($filterContentEl, {
        filter,
        $$targetRef: $$filterRef,
        onClose: () => {
          const currentVisibleFilterContents = visibleFilterContentsStream.getValue()
          visibleFilterContentsStream.next(
            _.filter(currentVisibleFilterContents, ({ filter }) =>
              id !== filter.id
            )
          )
        }
      })
    })
  ])
};
