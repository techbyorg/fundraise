import { z, useMemo } from 'zorium'
import * as rx from 'rxjs/operators'

import $appBar from 'frontend-shared/components/app_bar'
import useMeta from 'frontend-shared/services/use_meta'

import $entitySearch from '../../components/entity_search'

if (typeof window !== 'undefined') { require('./index.styl') }

export default function getSearchPage (entityType) {
  return function $searchPage ({ requestsStream }) {
    const { nteeStream, locationStream } = useMemo(() => {
      return {
        nteeStream: requestsStream.pipe(
          rx.map(({ route }) => route.params.ntee)
        ),
        locationStream: requestsStream.pipe(
          rx.map(({ route }) => route.params.location)
        )
      }
    }, [])

    useMeta(() => ({
      openGraph: {
        image: 'https://tdn.one/assets/images/home/fundraise_thumbnail.png'
      }
    }), [])

    return z('.p-search', [
      z($appBar, {
        hasLogo: true
        // $topLeftButton: z $buttonBack, {color: colors.$header500Icon}
      }),
      z($entitySearch, {
        nteeStream, locationStream, entityType
      })
    ])
  }
}
