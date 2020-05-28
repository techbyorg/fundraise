import {z, useContext, useMemo, useStream} from 'zorium'
RxBehaviorSubject = require('rxjs/BehaviorSubject').BehaviorSubject
RxReplaySubject = require('rxjs/ReplaySubject').ReplaySubject
RxObservable = require('rxjs/Observable').Observable
require 'rxjs/add/observable/of'

import $sheet from 'frontend-shared/components/sheet'
import $button from 'frontend-shared/components/button'

import $filterContent from '../filter_content'
import colors from '../../colors'
import context from '../../context'
import config from '../../config'

if window?
  require './index.styl'

export default $filterContentSheet = ({id, filter, onClose}) ->
  {lang} = useContext context

  {valueStreams} = useMemo ->
    valueStreams = new RxReplaySubject 1
    valueStreams.next filter.valueStreams.switch()
    {
      valueStreams
    }
  , []

  {filterValue, hasValue} = useStream ->
    filterValue: filter.valueStreams.switch()
    hasValue: valueStreams.switch().map (value) -> Boolean value
              .distinctUntilChanged((a, b) -> a is b) # don't rerender a bunch

  z '.z-filter-content-sheet',
    key: filter.id
    z $sheet,
      id: filter.id
      onClose: onClose
      $content:
        z '.z-filter-content-sheet_sheet',
          z '.actions',
            z '.reset',
              if hasValue
                z $button,
                  text: lang.get 'general.reset'
                  onclick: ->
                    filter.valueStreams.next RxObservable.of null
                    valueStreams.next RxObservable.of null
            z '.save',
              z $button,
                text: lang.get 'general.save'
                isPrimary: true
                onclick: ->
                  filter.valueStreams.next valueStreams.switch()
                  onClose()
          z '.title',
            filter?.title or filter?.name
          z $filterContent, {
            filter, filterValue, valueStreams, overlayAnchor: 'bottom-left'
          }
