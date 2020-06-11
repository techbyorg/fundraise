// TODO: This file was created by bulk-decaffeinate.
// Sanity-check the conversion and remove this comment.
import { z, useContext, useMemo, useEffect, useRef, useStream } from 'zorium'
import * as Rx from 'rxjs'
import * as rx from 'rxjs/operators'

import $positionedOverlay from 'frontend-shared/components/positioned_overlay'
import $button from 'frontend-shared/components/button'

import $filterContent from '../filter_content'
import colors from '../../colors'
import context from '../../context'
import config from '../../config'

if (typeof window !== 'undefined' && window !== null) {
  require('./index.styl')
}

export default function $filterPositionedOverlay (props) {
  const { filter, onClose, $$targetRef } = props
  const { lang } = useContext(context)

  const $$ref = useRef()
  const $$overlayRef = useRef() // have all child positionedOverlays be inside me

  var { valueStreams } = useMemo(function () {
    valueStreams = new Rx.ReplaySubject(1)
    valueStreams.next(filter.valueStreams.pipe(rx.switchAll()))
    return {
      valueStreams
    }
  }
  , [])

  useEffect(() => setTimeout(() => $$ref.current.classList.add('is-mounted'), 0)
    , [])

  const { filterValue, hasValue } = useStream(() => ({
    filterValue: filter.valueStreams.pipe(rx.switchAll()),

    hasValue: valueStreams.pipe(
      rx.switchAll(),
      rx.map(value => Boolean(value)),
      rx.distinctUntilChanged((a, b) => a === b) // don't rerender a bunch
    )
  }))

  return z('.z-filter-positioned-overlay',
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
        },
        z('.content',
          z('.title',
            filter?.title || filter?.name),
          z($filterContent, {
            filter, filterValue, valueStreams, $$parentRef: $$overlayRef
          })),
        z('.actions',
          z('.reset',
            hasValue
              ? z($button, {
                text: lang.get('general.reset'),
                onclick: () => {
                  filter.valueStreams.next(Rx.of(null))
                  return valueStreams.next(Rx.of(null))
                }
              }
              ) : undefined
          ),
          z('.save',
            z($button, {
              text: lang.get('general.save'),
              isPrimary: true,
              onclick: () => {
                filter.valueStreams.next(valueStreams.pipe(rx.switchAll()))
                return onClose()
              }
            }
            )
          )
        )
        )
    }
    )
  )
};
