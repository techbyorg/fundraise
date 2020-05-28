import {z, useMemo, useStream} from 'zorium'
RxBehaviorSubject = require('rxjs/BehaviorSubject').BehaviorSubject

import $filterContentDialog from '../filter_content_dialog'

if window?
  require './index.styl'

export default $searchTags = ({filter, title, placeholder}) ->
  {isDialogVisibleStream} = useMemo ->
    {
      isDialogVisibleStream: new RxBehaviorSubject false
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
