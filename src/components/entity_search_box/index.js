import { z, classKebab, useContext, useMemo, useStream } from 'zorium'
import * as _ from 'lodash-es'
import * as Rx from 'rxjs'
import * as rx from 'rxjs/operators'

import $button from 'frontend-shared/components/button'
import { searchIconPath } from 'frontend-shared/components/icon/paths'

import $searchInput from '../search_input'
import $searchTags from '../search_tags'
import context from '../../context'

if (typeof window !== 'undefined' && window !== null) {
  require('./index.styl')
}

export default function $entitySearchBox (props) {
  const { nameStream, filtersStream, hasHitSearchStream, hasSearched } = props
  const { lang, browser, cookie } = useContext(context)

  const { modeStream } = useMemo(function () {
    return {
      modeStream: new Rx.BehaviorSubject('tags')
    }
  }, [])

  const {
    mode, focusAreasFilter, statesFilter, breakpoint
  } = useStream(() => ({
    mode: modeStream,
    focusAreasFilter: filtersStream.pipe(rx.map(filters =>
      _.find(filters, { id: 'fundedNteeMajor' })
    )),
    statesFilter: filtersStream.pipe(rx.map(filters =>
      _.find(filters, { id: 'state' })
    )),
    breakpoint: browser.getBreakpoint()
  }))

  return z('.z-entity-search-box', { className: classKebab({ hasSearched }) }, [
    z('.title', [
      mode === 'specific'
        ? z('.text', lang.get('fundSearch.titleSpecific'))
        : z('.text', lang.get('fundSearch.titleFocusArea'))
    ]),
    z(`form.search-box.${mode}`, {
      onsubmit: (e) => {
        e.preventDefault()
        cookie.set('hasSearched', true)
        hasHitSearchStream.next(true)
      }
    }, [
      mode === 'specific'
        ? z($searchInput, {
          valueStream: nameStream,
          placeholder: lang.get('fundSearch.byNameEinPlaceholder')
        })
        : [
          z('.search-tags', [
            z($searchTags, {
              filter: focusAreasFilter,
              title: lang.get('fund.focusAreas'),
              placeholder: lang.get('fundSearch.focusAreasPlaceholder')
            })
          ]),
          z('.divider'),
          z('.search-tags', [
            z($searchTags, {
              filter: statesFilter,
              title: lang.get('general.location'),
              placeholder: lang.get('fundSearch.locationPlaceholder')
            })
          ])
        ],

      z('.button', [
        z($button, {
          type: 'submit',
          isPrimary: breakpoint !== 'mobile',
          icon: searchIconPath,
          text: lang.get('general.search')
        })
      ])
    ]),

    z('.alt', {
      onclick: () => {
        if (mode === 'specific') {
          modeStream.next('tags')
        } else {
          focusAreasFilter.valueStreams.next(Rx.of(null))
          statesFilter.valueStreams.next(Rx.of(null))
          modeStream.next('specific')
        }
      }
    },
    z('.or', lang.get('general.or')),
    mode === 'specific'
      ? z('.text', lang.get('fundSearch.byFocusArea'))
      : z('.text', lang.get('fundSearch.byNameEin'))
    )
  ])
};
