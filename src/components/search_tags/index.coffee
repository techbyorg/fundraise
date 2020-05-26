{z, useMemo, useStream} = require 'zorium'
RxBehaviorSubject = require('rxjs/BehaviorSubject').BehaviorSubject

$filterContentDialog = require '../filter_content_dialog'

if window?
  require './index.styl'

module.exports = $searchTags = ({filter, title, placeholder}) ->
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
