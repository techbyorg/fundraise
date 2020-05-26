{z, useContext, useMemo, useStream} = require 'zorium'
RxBehaviorSubject = require('rxjs/BehaviorSubject').BehaviorSubject

$dialog = require '../dialog'
colors = require '../../colors'
context = require '../../context'
config = require '../../config'

if window?
  require './index.styl'

module.exports = $requestRatingDialog = ({onClose}) ->
  {model, portal, lang} = useContext context

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
        $title: lang.get 'requestRating.title'
        $content: lang.get 'requestRating.text'
        cancelButton:
          text: lang.get 'general.no'
          colors:
            cText: colors.$bgText54
          onclick: ->
            localStorage.hasSeenRequestRating = '1'
            onClose?()
        submitButton:
          text: lang.get 'requestRating.rate'
          colors:
            cText: colors.$secondaryMain
          onclick: ->
            ga? 'send', 'event', 'requestRating', 'rate'
            localStorage.hasSeenRequestRating = '1'
            isLoadingStream.next true
            portal.call 'app.rate'
            .then ->
              isLoadingStream.next false
              model.overlay.close()
            .catch ->
              isLoadingStream.next false
