import {z, useContext, useMemo, useStream} from 'zorium'
import * as _ from 'lodash-es'
import * as Rx from 'rxjs'

import $tags from 'frontend-shared/components/tags'

import $filterContentDialog from '../filter_content_dialog'
import {nteeColors} from '../../colors'
import context from '../../context'

if window?
  require './index.styl'

export default $searchTags = ({filter, title, placeholder}) ->
  {lang} = useContext context

  {isDialogVisibleStream} = useMemo ->
    {
      isDialogVisibleStream: new Rx.BehaviorSubject false
    }
  , []

  {isDialogVisible} = useStream ->
    isDialogVisible: isDialogVisibleStream

  z '.z-search-tags', {
    onclick: ->
      isDialogVisibleStream.next true
  },
    z '.title', title
    z '.tags',
      if _.isEmpty filter?.value
        placeholder
      else
        z $tags, {
          maxVisibleCount: 6
          fitToContent: true
          isWrapped: false
          tags: _.filter _.map filter.value, (val, key) ->
            if val
              {
                text: filter.items[key].label
                background: nteeColors[key]?.bg
                color: nteeColors[key]?.fg
              }
        }
    if filter and isDialogVisible
      z $filterContentDialog, {
        filter, onClose: -> isDialogVisibleStream.next false
      }
