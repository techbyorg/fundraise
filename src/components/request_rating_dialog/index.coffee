{z, useMemo, useStream} = require 'zorium'
RxBehaviorSubject = require('rxjs/BehaviorSubject').BehaviorSubject

$dialog = require '../dialog'
config = require '../../config'
colors = require '../../colors'

if window?
  require './index.styl'

module.exports = RequestRatingDialog = ({model, onClose}) ->
  {isLoadingStream} = useMemo ->
    {
      isLoadingStream: new RxBehaviorSubject false
    }
  ,[]

  {isLoading} = useStream ->
    isLoading: isLoadingStream

  z '.z-request-rating-dialog',
      z $dialog,
        onClose: ->
          localStorage.hasSeenRequestRating = '1'
          onClose?()
        isVanilla: true
        isWide: true
        $title: model.l.get 'requestRating.title'
        $content: model.l.get 'requestRating.text'
        cancelButton:
          text: model.l.get 'general.no'
          colors:
            cText: colors.$bgText54
          onclick: ->
            localStorage.hasSeenRequestRating = '1'
            onClose?()
        submitButton:
          text: model.l.get 'requestRating.rate'
          colors:
            cText: colors.$secondaryMain
          onclick: ->
            ga? 'send', 'event', 'requestRating', 'rate'
            localStorage.hasSeenRequestRating = '1'
            isLoadingStream.next true
            model.portal.call 'app.rate'
            .then ->
              isLoadingStream.next false
              model.overlay.close()
            .catch ->
              isLoadingStream.next false
