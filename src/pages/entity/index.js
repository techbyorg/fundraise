import { z, useContext, useMemo, useStream } from 'zorium'
import * as _ from 'lodash-es'
import * as rx from 'rxjs/operators'

import $appBar from 'frontend-shared/components/app_bar'
import $buttonBack from 'frontend-shared/components/button_back'
import useMeta from 'frontend-shared/services/use_meta'

import $entity from '../../components/entity'
import colors from '../../colors'
import context from '../../context'

if (typeof window !== 'undefined' && window !== null) {
  require('./index.styl')
}

export default function getEntityPage (entityType) {
  return function $entityPage ({ requestsStream }) {
    const { model } = useContext(context)

    const { placeholderNameStream, entityStream, tabStream } = useMemo(() => {
      return {
        // for smoother loading
        placeholderNameStream: requestsStream.pipe(
          rx.map(({ route }) => _.startCase(route.params.slug))
        ),
        entityStream: requestsStream.pipe(
          rx.switchMap(({ route }) => model[entityType].getByEin(route.params.ein))
        ),
        tabStream: requestsStream.pipe(rx.map(({ route }) => route.params.tab))
      }
    }, [])

    const { entity } = useStream(() => ({
      entity: entityStream
    }))

    useMeta(() => {
      if (entity) {
        return { title: entity?.name }
      }
    }, [entity?.name])

    return z('.p-entity', [
      z($appBar, {
        // title: entity?.name
        hasLogo: true,
        isRaised: true,
        isContained: false,
        $topLeftButton: z($buttonBack, {
          color: colors.$header500Icon
        })
      }),
      z($entity, { placeholderNameStream, entityStream, tabStream, entityType })
    ])
  }
}
