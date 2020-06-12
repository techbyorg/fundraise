import { z, useMemo, useStream } from 'zorium'
import * as _ from 'lodash-es'
import * as Rx from 'rxjs'

import $tags from 'frontend-shared/components/tags'

import $filterDialog from '../filter_dialog'

if (typeof window !== 'undefined' && window !== null) {
  require('./index.styl')
}

export default function $searchTags ({ filter, title, placeholder }) {
  const { isDialogVisibleStream } = useMemo(() => ({
    isDialogVisibleStream: new Rx.BehaviorSubject(false)
  })
  , [])

  const { isDialogVisible } = useStream(() => ({
    isDialogVisible: isDialogVisibleStream
  }))

  return z('.z-search-tags', {
    onclick: () => {
      return isDialogVisibleStream.next(true)
    }
  }, [
    z('.title', title),
    z('.tags', [
      _.isEmpty(filter?.value)
        ? placeholder
        : z($tags, {
          maxVisibleCount: 6,
          fitToContent: true,
          isNoWrap: false,
          tags: filter.getTagsFn(filter.value)
        })
    ]),
    filter && isDialogVisible &&
      z($filterDialog, {
        filter, onClose () { return isDialogVisibleStream.next(false) }
      })
  ])
};
