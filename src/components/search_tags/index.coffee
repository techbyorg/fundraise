import {z, useMemo, useStream} from 'zorium'
import * as Rx from 'rxjs'

import $filterContentDialog from '../filter_content_dialog'

if window?
  require './index.styl'

export default $searchTags = ({filter, title, placeholder}) ->
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
    z '.tags', placeholder
    if filter and isDialogVisible
      z $filterContentDialog, {
        filter, onClose: -> isDialogVisibleStream.next false
      }
