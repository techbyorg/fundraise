import {z, classKebab, useContext, useMemo, useStream} from 'zorium'
import * as _ from 'lodash-es'
import * as Rx from 'rxjs'
import * as rx from 'rxjs/operators'

import $icon from 'frontend-shared/components/icon'
import {closeIconPath} from 'frontend-shared/components/icon/paths'
import $primaryInput from 'frontend-shared/components/primary_input'
import FormatService from 'frontend-shared/components/services/format'

import context from '../../context'
import config from '../../config'

if window?
  require './index.styl'

SEARCH_DEBOUNCE = 300

export default $irsSearch = ({irsType = 'irsFund', hintText}) ->
  {model, router} = useContext context

  {nameValueStream, debouncedNameValueStream, isEntitiesVisibleStream,
    selectedEntityStream} = useMemo ->

    nameValueStream = new Rx.BehaviorSubject ''
    {
      nameValueStream
      debouncedNameValueStream: nameValueStream.pipe(
        rx.debounceTime(SEARCH_DEBOUNCE)
      )
      isEntitiesVisibleStream: new Rx.BehaviorSubject false
      selectedEntityStream: new Rx.BehaviorSubject null
    }
  , []

  {name, selectedEntity, isEntitiesVisible, entities} = useStream ->
    name: nameValueStream
    selectedEntity: selectedEntityStream
    isEntitiesVisible: isEntitiesVisibleStream
    entities: debouncedNameValueStream.pipe rx.switchMap (name) =>
      isEntitiesVisibleStream.next true
      unless name
        return Rx.of null
      model[irsType].search {
        limit: 50
        query:
          multi_match:
            query: name
            type: 'bool_prefix'
            fields: ['name', 'name._2gram']
      }

  isEntitiesVisible = not selectedEntity and not _.isEmpty entities

  z '.z-irs-search', {
    className: classKebab {isEntitiesVisible}
  },
    z '.input',
      if selectedEntity
        z '.selected',
          z '.name', selectedEntity.name
          z '.cancel',
            z $icon,
              icon: closeIconPath
              isTouchTarget: false
              onclick: =>
                nameValueStream.next ''

      else
        z $primaryInput, {valueStream: nameValueStream, hintText}
    z '.entities',
      _.map entities?.nodes, (entity) =>
        router.link z 'a.entity', {
          href:
            if irsType is 'irsFund'
              router.getFund entity
            else
              router.getOrg entity
          className: classKebab {
            isSelected: selectedEntity?.id is entity.id
          }
        },
          z '.info',
            z '.name',
              entity.name
            if irsType is 'irsPerson'
              z '.sub',
                entity.irsName
