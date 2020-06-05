import {z, useContext, useMemo, useStream} from 'zorium'
import * as _ from 'lodash-es'
import * as Rx from 'rxjs'

import $tags from 'frontend-shared/components/tags'

import $filterDialog from '../filter_dialog'
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
          isNoWrap: false
          tags: filter.getTagsFn filter.value
        }
    if filter and isDialogVisible
      z $filterDialog, {
        filter, onClose: -> isDialogVisibleStream.next false
      }
