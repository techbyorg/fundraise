z = require 'zorium'
RxBehaviorSubject = require('rxjs/BehaviorSubject').BehaviorSubject

PrimaryInput = require '../primary_input'
Icon = require '../icon'
Button = require '../button'
Icon = require '../icon'
colors = require '../../colors'
config = require '../../config'

if window?
  require './index.styl'

module.exports = class SignIn
  constructor: ({@model, @router, @mode, entityType}) ->
    @nameValue = new RxBehaviorSubject ''
    @nameError = new RxBehaviorSubject null
    @$nameInput = new PrimaryInput
      value: @nameValue
      error: @nameError

    @passwordValue = new RxBehaviorSubject ''
    @passwordError = new RxBehaviorSubject null
    @$passwordInput = new PrimaryInput
      value: @passwordValue
      error: @passwordError

    @emailValue = new RxBehaviorSubject ''
    @emailError = new RxBehaviorSubject null
    @$emailInput = new PrimaryInput
      value: @emailValue
      error: @emailError

    @entityValue = new RxBehaviorSubject null

    @$submitButton = new Button()
    @$resetPasswordButton = new Button()

    @mode ?= new RxBehaviorSubject 'signIn'

    @state = z.state
      me: @model.user.getMe()
      mode: @mode
      entityType: entityType
      isLoading: false
      hasError: false

  beforeUnmount: =>
    @state.set hasError: false

  join: (e) =>
    e?.preventDefault()

    {entityType} = @state.getValue()

    @state.set isLoading: true, hasError: false
    @nameError.next null
    @emailError.next null
    @passwordError.next null

    @model.auth.join {
      name: @nameValue.getValue()
      password: @passwordValue.getValue()
      email: @emailValue.getValue()
    }
    # Promise.resolve true # FIXME
    .then =>
      # model = if entityType is 'org' then @model.org else @model.fund
      selectedEntity = @entityValue.getValue()
      @model.entity.onboard {
        ein: selectedEntity?.ein
        type: entityType
      }
      # HACK: give time for invalidate to work
      setTimeout =>
        console.log 'DONE!!!!!!!!!!!!!!!!!!!!!'
        @state.set isLoading: false
        @model.user.getMe().take(1).subscribe =>
          @router.go 'dashboard'
      , 0
    .catch (err) =>
      err = try
        JSON.parse err.message
      catch
        {}
      errorSubject = switch err.info.field
        when 'name' then @nameError
        when 'email' then @emailError
        when 'password' then @passwordError
        else @emailError
      errorSubject.next @model.l.get err.info.langKey
      @state.set isLoading: false

  reset: (e) =>
    e?.preventDefault()
    @state.set isLoading: true, hasError: false
    @emailError.next null

    @model.auth.resetPassword {
      email: @emailValue.getValue()
    }
    .then =>
      @state.set isLoading: false
      @model.overlay.close {action: 'complete'}
    .catch (err) =>
      err = try
        JSON.parse err.message
      catch
        {}
      errorSubject = switch err.info.field
        when 'email' then @emailError
        else @emailError
      errorSubject.next @model.l.get err.info.langKey
      @state.set isLoading: false

  signIn: (e) =>
    e?.preventDefault()
    @state.set isLoading: true, hasError: false
    @emailError.next null
    @passwordError.next null

    @model.auth.login {
      email: @emailValue.getValue()
      password: @passwordValue.getValue()
    }
    .then =>
      @state.set isLoading: false
      # give time for invalidate to work
      setTimeout =>
        @model.user.getMe().take(1).subscribe =>
          @model.overlay.close {action: 'complete'}
      , 0
    .catch (err) =>
      @state.set hasError: true
      err = try
        JSON.parse err.message
      catch
        {}
      errorSubject = switch err.info?.field
        when 'password' then @passwordError
        else @emailError

      errorSubject.next @model.l.get err.info?.langKey
      @state.set isLoading: false

  cancel: =>
    @model.overlay.close 'cancel'

  render: =>
    {me, isLoading, mode, entityType, hasError} = @state.getValue()

    isMember = @model.user.isMember me
    entityValue = @entityValue.getValue()

    z '.z-sign-in',
      z '.title',
        if mode is 'join'
        then @model.l.get 'signInOverlay.join'
        else @model.l.get 'signInOverlay.signIn'
      if mode is 'join' and isMember
        z '.content',
          @model.l.get 'signIn.alreadyLoggedIn'
      else if mode
        z 'form.content',
          if mode is 'join'
            z '.input',
              z @$nameInput, {
                hintText: @model.l.get 'general.name'
                type: 'text'
              }
          z '.input',
            z @$emailInput, {
              hintText: @model.l.get 'general.email'
              type: 'email'
            }
          if mode isnt 'reset'
            z '.input', {key: 'password-input'},
              z @$passwordInput, {
                hintText: @model.l.get 'general.password'
                type: 'password'
              }

          if mode is 'join'
            z '.terms',
              @model.l.get 'signInOverlay.terms', {
                replacements: {tos: ' '}
              }
              z 'a', {
                href: "https://#{config.HOST}/policies"
                target: '_system'
                onclick: (e) =>
                  e.preventDefault()
                  @model.portal.call 'browser.openWindow', {
                    url: "https://#{config.HOST}/policies"
                    target: '_system'
                  }
              }, 'TOS'
          z '.actions',
            z '.button',
              z @$submitButton,
                isPrimary: true
                isDisabled: not entityValue # FIXME
                text: if isLoading \
                      then @model.l.get 'general.loading' \
                      else if mode is 'reset' \
                      then @model.l.get 'signInOverlay.emailResetLink' \
                      else if mode is 'join' \
                      then @model.l.get 'signInOverlay.createAccount' \
                      else @model.l.get 'general.signIn'
                onclick: (e) =>
                  if mode is 'reset'
                    @reset e
                  else if mode is 'join'
                    @join e
                  else
                    @signIn e
                type: 'submit'
            # TODO: re-enable after removing username req
            # if hasError and mode is 'signIn'
            #   z '.button',
            #     z @$resetPasswordButton,
            #       isInverted: true
            #       text: @model.l.get 'signInOverlay.resetPassword'
            #       onclick: =>
            #         @mode.next 'reset'
