// TODO: This file was created by bulk-decaffeinate.
// Sanity-check the conversion and remove this comment.
import { z, classKebab, useContext, useMemo, useStream } from 'zorium'
import * as _ from 'lodash-es'
import * as Rx from 'rxjs'
import * as rx from 'rxjs/operators'

import $icon from 'frontend-shared/components/icon'
import { closeIconPath } from 'frontend-shared/components/icon/paths'
import $primaryInput from 'frontend-shared/components/primary_input'

import context from '../../context'

if (typeof window !== 'undefined' && window !== null) {
  require('./index.styl')
}

const SEARCH_DEBOUNCE = 300

export default function $irsSearch (...args) {
  const obj = args[0]
  const val = obj.irsType
  const irsType = val != null ? val : 'irsFund'
  const {
    hintText
  } = obj
  const { model, router } = useContext(context)

  var {
    nameValueStream, debouncedNameValueStream, isEntitiesVisibleStream,
    selectedEntityStream
  } = useMemo(function () {
    nameValueStream = new Rx.BehaviorSubject('')
    return {
      nameValueStream,
      debouncedNameValueStream: nameValueStream.pipe(
        rx.debounceTime(SEARCH_DEBOUNCE)
      ),
      isEntitiesVisibleStream: new Rx.BehaviorSubject(false),
      selectedEntityStream: new Rx.BehaviorSubject(null)
    }
  }
  , [])

  let { selectedEntity, isEntitiesVisible, entities } = useStream(() => ({
    selectedEntity: selectedEntityStream,
    isEntitiesVisible: isEntitiesVisibleStream,

    entities: debouncedNameValueStream.pipe(rx.switchMap(name => {
      isEntitiesVisibleStream.next(true)
      if (!name) {
        return Rx.of(null)
      }
      return model[irsType].search({
        limit: 50,
        query: {
          multi_match: {
            query: name,
            type: 'bool_prefix',
            fields: ['name', 'name._2gram']
          }
        }
      })
    }))
  }))

  isEntitiesVisible = !selectedEntity && !_.isEmpty(entities)

  return z('.z-irs-search', {
    className: classKebab({ isEntitiesVisible })
  },
  z('.input',
    selectedEntity
      ? z('.selected',
        z('.name', selectedEntity.name),
        z('.cancel',
          z($icon, {
            icon: closeIconPath,
            onclick: () => {
              return nameValueStream.next('')
            }
          }
          )
        )
      )

      : z($primaryInput, { valueStream: nameValueStream, hintText })),
  z('.entities',
    _.map(entities?.nodes, entity => {
      return router.link(z('a.entity', {
        href:
            irsType === 'irsFund'
              ? router.getFund(entity)
              : router.getOrg(entity),
        className: classKebab({
          isSelected: selectedEntity?.id === entity.id
        })
      },
      z('.info',
        z('.name',
          entity.name),
        irsType === 'irsPerson'
          ? z('.sub',
            entity.irsName) : undefined
      )
      )
      )
    })
  )
  )
};