import { z, useContext, useMemo, useStream } from 'zorium'
import * as Rx from 'rxjs'
import * as rx from 'rxjs/operators'

import $sheet from 'frontend-shared/components/sheet'
import $button from 'frontend-shared/components/button'
import { streams } from 'frontend-shared/services/obs'

import $filterContent from '../filter_content'
import context from '../../context'

if (typeof window !== 'undefined' && window !== null) {
  require('./index.styl')
}

export default function $filterSheet ({ id, filter, onClose }) {
  const { lang } = useContext(context)

  const { valueStreams } = useMemo(function () {
    const valueStreams = streams(filter.valueStreams.stream)
    return {
      valueStreams
    }
  }, [])

  const { filterValue, hasValue } = useStream(() => ({
    filterValue: filter.valueStreams.stream,
    hasValue: valueStreams.pipe(
      rx.switchAll(),
      rx.map(value => Boolean(value)),
      rx.distinctUntilChanged((a, b) => a === b) // don't rerender a bunch
    )
  }))

  return z('.z-filter-sheet', [
    { key: filter.id },
    z($sheet, {
      id: filter.id,
      onClose,
      $content:
        z('.z-filter-sheet_sheet', [
          z('.actions', [
            z('.reset', [
              hasValue &&
                z($button, {
                  text: lang.get('general.reset'),
                  onclick () {
                    filter.valueStreams.next(Rx.of(null))
                    return valueStreams.next(Rx.of(null))
                  }
                })
            ]),
            z('.save',
              z($button, {
                text: lang.get('general.save'),
                isPrimary: true,
                onclick () {
                  filter.valueStreams.next(valueStreams.stream)
                  return onClose()
                }
              }
              )
            )
          ]),
          z('.title', filter?.title || filter?.name),
          z($filterContent, {
            filter, filterValue, valueStreams, overlayAnchor: 'bottom-left'
          })
        ])
    })
  ])
};
