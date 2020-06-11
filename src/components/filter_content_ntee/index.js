import {z, Boundary, Fragment, Suspense, classKebab, lazy, useContext, useEffect, useMemo, useStream} from 'zorium'
import * as _ from 'lodash-es'
import * as Rx from 'rxjs'
import * as rx from 'rxjs/operators'

import $checkbox from 'frontend-shared/components/checkbox'
import $input from 'frontend-shared/components/input'
import $icon from 'frontend-shared/components/icon'
import {
  searchIconPath, chevronDownIconPath, chevronUpIconPath
} from 'frontend-shared/components/icon/paths'
import $spinner from 'frontend-shared/components/spinner'

import context from '../../context'

if window?
  require './index.styl'

SEARCH_DEBOUNCE_MS = 300

getNtees = ->
  `import(/* webpackChunkName: "ntee" */'./ntee.coffee')`
  .then (module) -> module.default

searchLabel = (label, search) ->
  label.toLowerCase().indexOf(search.toLowerCase()) isnt -1

_$filterContentNtee = lazy ->
  getNtees().then (ntees) ->
    (props) ->
      {filterValueStr, resetValue, filter, valueStreams, filterValue} = props
      {lang} = useContext context

      {nteeValueStreams, groupTogglesStream, searchStream,
        groupsStream, searchStream} = useMemo ->
        searchStream = new Rx.BehaviorSubject ''
        groupTogglesStream = new Rx.BehaviorSubject {}

        searchAndGroupTogglesStream = Rx.combineLatest(
          searchStream.pipe(
            rx.filter (search) -> search?.length > 2
            rx.startWith ''
            rx.debounceTime SEARCH_DEBOUNCE_MS
          )
          groupTogglesStream, (vals...) -> vals
        )

        nteeValueStreams = _.reduce ntees, (obj, {label, children}, key) ->
          obj[key] = new Rx.BehaviorSubject filterValue?.nteeMajors[key]
          _.forEach children, (label, key) ->
            obj[key] = new Rx.BehaviorSubject filterValue?.ntees[key]
          obj
        , {}

        groupsStream = searchAndGroupTogglesStream.pipe rx.map ([search, groupToggles]) ->
          _.mapValues ntees, ({label, children}, key) =>
            hasMatch = searchLabel label, search
            children = _.map children, (label, key) ->
              isValueSet = nteeValueStreams[key].getValue()
              {
                key
                label
                valueStream: nteeValueStreams[key]
                isVisible: isValueSet or (search and searchLabel label, search)
              }
            hasChildrenMatches = _.find children, {isVisible: true}
            isOpen = (hasChildrenMatches and groupToggles[key] isnt false) or
                      groupToggles[key]
            {
              key, label, isOpen, hasMatch, children
              isVisible: hasMatch or hasChildrenMatches
              valueStream: nteeValueStreams[key]
            }

        valueStreams.next Rx.combineLatest(
          _.values(nteeValueStreams), (vals...) -> vals
        ).pipe rx.map (vals) ->
          unless _.isEmpty _.filter(vals)
            keys = _.keys nteeValueStreams
            _.reduce vals, (obj, val, i) ->
              key = keys[i]
              if val and key.length is 1
                obj.nteeMajors[key] = val
              else if val
                obj.ntees[key] = val
              obj
            , {nteeMajors: {}, ntees: {}}

        {
          nteeValueStreams
          groupTogglesStream
          searchStream
          groupsStream
          searchStream
        }
      , []

      useEffect ->
        console.log 'eff', filterValue
        _.forEach ntees, ({label, children}, key) ->
          nteeValueStreams[key].next filterValue?.nteeMajors[key]
          _.forEach children, (label, key) ->
            nteeValueStreams[key].next filterValue?.ntees[key]
        , {}
      , [filterValueStr, resetValue]

      {groupToggles, search, groups} = useStream ->
        groupToggles: groupTogglesStream
        search: searchStream
        groups: groupsStream

      z Fragment,
        z '.search',
          z $input, {
            icon: searchIconPath
            placeholder: lang.get 'filterContentNtee.searchPlaceholder'
            valueStream: searchStream
          }
        _.map groups, (group) ->
          {key, valueStream, label, children, isOpen, isVisible} = group
          z '.group', {
            className: classKebab {isVisible}
          },
            z 'label.label',
              z '.checkbox',
                z $checkbox, {
                  valueStream
                  onChange: (val) ->
                    if val
                      groupTogglesStream.next(
                        _.defaults {"#{key}": false}, groupToggles
                      )
                }
              z '.text', label or 'fixme'
              unless search
                z '.open', {
                  onclick: (e) ->
                    e.preventDefault()
                    if isOpen
                      groupTogglesStream.next(
                        _.defaults {"#{key}": false}, groupToggles
                      )
                    else
                      groupTogglesStream.next(
                        _.defaults {"#{key}": true}, groupToggles
                      )
                },
                  z $icon,
                    icon: if isOpen \
                          then chevronUpIconPath \
                          else chevronDownIconPath

            if isOpen # having these always in dom is slow on first load
              z '.children',
              _.map children, ({key, isVisible, valueStream, label}) ->
                # if group is open and no search, show all
                isVisible or= not search
                z 'label.label', {
                  key
                  className: classKebab {isVisible}
                },
                  z '.checkbox',
                    z $checkbox, {
                      valueStream
                      onChange: (val) ->
                        if val
                          # disable parent
                          nteeValueStreams[key.substr(0, 1)].next false
                    }
                  z '.text', label or 'fixme'



export default $filterContentNtee = (props) ->
  z '.z-filter-content-ntee',
    z Boundary, {fallback: z '.error', 'err'},
      z Suspense, {fallback: z $spinner},
        z _$filterContentNtee, props
