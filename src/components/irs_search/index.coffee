{z, classKebab, useContext, useMemo, useStream} = require 'zorium'
_isEmpty = require 'lodash/isEmpty'
_map = require 'lodash/map'
RxBehaviorSubject = require('rxjs/BehaviorSubject').BehaviorSubject
RxObservable = require('rxjs/Observable').Observable
require 'rxjs/add/observable/of'
require 'rxjs/add/operator/debounceTime'

$primaryInput = require 'frontend-shared/components/primary_input'
FormatService = require 'frontend-shared/components/services/format'

$icon = require '../icon'
context = require '../../context'
config = require '../../config'

if window?
  require './index.styl'

SEARCH_DEBOUNCE = 300

module.exports = $irsSearch = ({irsType = 'irsFund', hintText}) ->
  {model, router} = useContext context

  {nameValueStream, debouncedNameValueStream, isEntitiesVisibleStream,
    selectedEntityStream} = useMemo ->

    nameValueStream = new RxBehaviorSubject ''
    {
      nameValueStream
      debouncedNameValueStream: nameValueStream.debounceTime(SEARCH_DEBOUNCE)
      isEntitiesVisibleStream: new RxBehaviorSubject false
      selectedEntityStream: new RxBehaviorSubject null
    }
  , []

  {name, selectedEntity, isEntitiesVisible, entities} = useStream ->
    name: nameValueStream
    selectedEntity: selectedEntityStream
    isEntitiesVisible: isEntitiesVisibleStream
    entities: debouncedNameValueStream.switchMap (name) =>
      isEntitiesVisibleStream.next true
      unless name
        return RxObservable.of null
      model[irsType].search {
        limit: 50
        query:
          multi_match:
            query: name
            type: 'bool_prefix'
            fields: ['name', 'name._2gram']
      }

  isEntitiesVisible = not selectedEntity and not _isEmpty entities

  z '.z-irs-search', {
    className: classKebab {isEntitiesVisible}
  },
    z '.input',
      if selectedEntity
        z '.selected',
          z '.name', selectedEntity.name
          z '.cancel',
            z $icon,
              icon: 'close'
              isTouchTarget: false
              onclick: =>
                nameValueStream.next ''

      else
        z $primaryInput, {valueStream: nameValueStream, hintText}
    z '.entities',
      _map entities?.nodes, (entity) =>
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
