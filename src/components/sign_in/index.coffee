{z, useMemo, useStream} = require 'zorium'
RxBehaviorSubject = require('rxjs/BehaviorSubject').BehaviorSubject

$primaryInput = require '../primary_input'
$button = require '../button'
colors = require '../../colors'
config = require '../../config'

if window?
  require './index.styl'

# FIXME: passing stream to child component causes 2 renders of child
# since state updates in 2 places

module.exports = SignIn = ({model, router, modeStream}) ->
  console.log 'render sign in'
  {nameValueStream, nameErrorStream, passwordValueStream, passwordErrorStream,
    emailValueStream, emailErrorStream, modeStream,
    isLoadingStream, hasErrorStream} = useMemo ->
    {
      nameValueStream: new RxBehaviorSubject ''
      nameErrorStream: new RxBehaviorSubject null
      passwordValueStream: new RxBehaviorSubject ''
      passwordErrorStream: new RxBehaviorSubject null
      emailValueStream: new RxBehaviorSubject ''
      emailErrorStream: new RxBehaviorSubject null
      modeStream: modeStream or new RxBehaviorSubject 'signIn'
    }
  , []

  {me, mode, isLoading, hasError, nameValue} = useStream ->
    me: model.user.getMe()
    mode: modeStream
    isLoading: isLoadingStream
    hasError: hasErrorStream

  join = (e) ->
    e?.preventDefault()
    isLoadingStream.next true
    hasErrorStream.next false
    nameErrorStream.next null
    emailErrorStream.next null
    passwordErrorStream.next null

    model.auth.join {
      name: nameValueStream.getValue()
      password: passwordValueStream.getValue()
      email: emailValueStream.getValue()
    }
    .then ->
      isLoadingStream.next false
      # give time for invalidate to work
      setTimeout ->
        model.user.getMe().take(1).subscribe ->
          model.overlay.close {action: 'complete'}
      , 0
    .catch (err) ->
      err = try
        JSON.parse err.message
      catch
        {}
      errorStream = switch err.info.field
        when 'name' then nameErrorS
        when 'email' then emailErrorStream
        when 'password' then passwordErrorS
        else emailErrorStream
      errorStream.next model.l.get err.info.langKey
      isLoadingStream.next false

  reset = (e) ->
    e?.preventDefault()
    isLoadingStream.next true
    hasErrorStream.next false
    emailErrorStream.next null

    model.auth.resetPassword {
      email: emailValueStream.getValue()
    }
    .then ->
      isLoadingStream.next false
      model.overlay.close {action: 'complete'}
    .catch (err) ->
      err = try
        JSON.parse err.message
      catch
        {}
      errorStream = switch err.info.field
        when 'email' then emailErrorStream
        else emailErrorStream
      errorStream.next model.l.get err.info.langKey
      isLoadingStream.next false

  signIn = (e) ->
    e?.preventDefault()
    isLoadingStream.next true
    hasErrorStream.next false
    emailErrorStream.next null
    passwordErrorStream.next null

    model.auth.login {
      email: emailValueStream.getValue()
      password: passwordValueStream.getValue()
    }
    .then ->
      isLoadingStream.next false
      # give time for invalidate to work
      setTimeout ->
        model.user.getMe().take(1).subscribe ->
          model.overlay.close {action: 'complete'}
      , 0
    .catch (err) ->
      hasErrorStream.next true
      err = try
        JSON.parse err.message
      catch
        {}
      errorStream = switch err.info?.field
        when 'password' then passwordErrorStream
        else emailErrorStream

      errorStream.next model.l.get err.info?.langKey
      isLoadingStream.next false

  # cancel = ->
  #   model.overlay.close 'cancel'

  isMember = model.user.isMember me

  z '.z-sign-in',
    z '.title',
      if mode is 'join'
      then model.l.get 'signInOverlay.join'
      else model.l.get 'signInOverlay.signIn'
    if mode is 'join' and isMember
      z '.content',
        model.l.get 'signIn.alreadyLoggedIn'
    else if mode
      z 'form.content',
        if mode is 'join'
          z '.input',
            z $primaryInput, {
              valueStream: nameValueStream
              errorStream: nameErrorStream
              hintText: model.l.get 'general.name'
              type: 'text'
            }
        z '.input',
          z $primaryInput, {
            valueStream: emailValueStream
            errorStream: emailErrorStream
            hintText: model.l.get 'general.email'
            type: 'email'
          }
        if mode isnt 'reset'
          z '.input', {key: 'password-input'},
            z $primaryInput, {
              valueStream: passwordValueStream
              errorStream: passwordErrorStream
              hintText: model.l.get 'general.password'
              type: 'password'
            }

        if mode is 'join'
          z '.terms',
            model.l.get 'signInOverlay.terms', {
              replacements: {tos: ' '}
            }
            z 'a', {
              href: "https://#{config.HOST}/policies"
              target: '_system'
              onclick: (e) ->
                e.preventDefault()
                model.portal.call 'browser.openWindow', {
                  url: "https://#{config.HOST}/policies"
                  target: '_system'
                }
            }, 'TOS'
        z '.actions',
          z '.button',
            z $button,
              isPrimary: true
              text: if isLoading \
                    then model.l.get 'general.loading' \
                    else if mode is 'reset' \
                    then model.l.get 'signInOverlay.emailResetLink' \
                    else if mode is 'join' \
                    then model.l.get 'signInOverlay.createAccount' \
                    else model.l.get 'general.signIn'
              onclick: (e) ->
                if mode is 'reset'
                  reset e
                else if mode is 'join'
                  join e
                else
                  signIn e
              type: 'submit'
          # TODO: re-enable after removing username req
          # if hasError and mode is 'signIn'
          #   z '.button',
          #     z $button,
          #       isInverted: true
          #       text: model.l.get 'signInOverlay.resetPassword'
          #       onclick: ->
          #         mode.next 'reset'
