import { z, useContext, useMemo, useEffect, useRef, useStream } from 'zorium'
import * as Rx from 'rxjs'
import * as rx from 'rxjs/operators'

import $positionedOverlay from 'frontend-shared/components/positioned_overlay'
import $button from 'frontend-shared/components/button'
import { streams } from 'frontend-shared/services/obs'

import $filterContent from '../filter_content'
import context from '../../context'

if (typeof window !== 'undefined' && window !== null) {
  require('./index.styl')
}

export default function $filterPositionedOverlay (props) {
  const { filter, onClose, $$targetRef } = props
  const { lang } = useContext(context)

  const $$ref = useRef()
  const $$overlayRef = useRef() // have all child positionedOverlays be inside me

  const { valueStreams } = useMemo(function () {
    const valueStreams = streams(filter.valueStreams.stream)
    return {
      valueStreams
    }
  }, [])

  useEffect(() => {
    setTimeout(() => $$ref.current.classList.add('is-mounted'), 0)
  }, [])

  const { filterValue, hasValue } = useStream(() => ({
    filterValue: filter.valueStreams.stream,
    hasValue: valueStreams.pipe(
      rx.switchAll(),
      rx.map(value => Boolean(value)),
      rx.distinctUntilChanged((a, b) => a === b) // don't rerender a bunch
    )
  }))

  return z('.z-filter-positioned-overlay', [
    z($positionedOverlay, {
      onClose,
      $$targetRef,
      $$ref: $$overlayRef,
      repositionOnChangeStr: filterValue,
      anchor: 'top-left',
      offset: {
        y: 8
      },
      $content:
        z('.z-filter-positioned-overlay_content', {
          ref: $$ref
        }, [
          z('.content', [
            z('.title', filter?.title || filter?.name),
            z($filterContent, {
              filter, filterValue, valueStreams, $$parentRef: $$overlayRef
            })
          ]),
          z('.actions', [
            z('.reset', [
              hasValue &&
                z($button, {
                  text: lang.get('general.reset'),
                  onclick: () => {
                    filter.valueStreams.next(Rx.of(null))
                    return valueStreams.next(Rx.of(null))
                  }
                })
            ]),
            z('.save', [
              z($button, {
                text: lang.get('general.save'),
                isPrimary: true,
                onclick: () => {
                  filter.valueStreams.next(valueStreams.stream)
                  return onClose()
                }
              })
            ])
          ])
        ])
    })
  ])
};
