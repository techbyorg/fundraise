_pick = require 'lodash/pick'
RxObservable = require('rxjs/Observable').Observable
require 'rxjs/add/observable/defer'
require 'rxjs/add/operator/toPromise'
require 'rxjs/add/observable/fromPromise'
require 'rxjs/add/operator/switchMap'
require 'rxjs/add/operator/take'
require 'rxjs/add/operator/publishReplay'

Environment = require '../services/environment'
config = require '../config'

module.exports = class Auth
  constructor: (options) ->
    {@exoid, @pushToken, @l, @cookie, @userAgent, @portal} = options

    @waitValidAuthCookie = RxObservable.defer =>
      accessToken = @cookie.get config.AUTH_COOKIE
      language = @l.getLanguageStr()
      (if accessToken
        @exoid.getCached 'graphql',
          graphql: '''
            query Query { me { id, name, data { bio } } }
          '''
        .then (user) =>
          if user?
            return {data: userLoginAnon: {accessToken}}
          @exoid.call 'graphql',
            graphql: '''
              query Query { me { id, name, data { bio } } }
            '''
          .then ->
            return {data: userLoginAnon: {accessToken}}
        .catch =>
          @exoid.call 'graphql',
            # FIXME: cleanup all this duplication
            graphql: '''
              mutation LoginAnon {
                userLoginAnon {
                  accessToken
                }
              }
            '''
      else
        @exoid.call 'graphql',
          graphql: '''
            mutation LoginAnon {
              userLoginAnon {
                accessToken
              }
            }
          ''')
      .then ({data}) =>
        console.log 'RESPONSE', data
        @setAccessToken data?.userLoginAnon.accessToken
    .publishReplay(1).refCount()

  setAccessToken: (accessToken) =>
    @cookie.set config.AUTH_COOKIE, accessToken

  logout: =>
    @setAccessToken ''
    language = @l.getLanguageStr()
    @exoid.call 'graphql',
      graphql: '''
        mutation LoginAnon {
          userLoginAnon {
            accessToken
          }
        }
      '''
    .then ({data}) =>
      @setAccessToken data?.userLoginAnon.accessToken
      @exoid.invalidateAll()

  join: ({name, email, password} = {}) =>
    @exoid.call 'auth.join', {name, email, password}
    .then ({accessToken}) =>
      @setAccessToken accessToken
      @exoid.invalidateAll()

  resetPassword: ({email} = {}) =>
    @exoid.call 'auth.resetPassword', {email}

  afterLogin: ({accessToken}) =>
    @setAccessToken accessToken
    @exoid.invalidateAll()
    pushToken = @pushToken.getValue()
    if pushToken
      pushToken ?= 'none'
      @portal.call 'app.getDeviceId'
      .catch -> null
      .then (deviceId) =>
        sourceType = if Environment.isAndroid() \
                     then 'android' \
                     else 'ios-fcm'
        @call 'pushTokens.upsert', {tokenStr: pushToken, sourceType, deviceId}
      .catch -> null

  login: ({email, password} = {}) =>
    @exoid.call 'graphql',
      graphql: '''
        mutation UserLoginEmail($email: String!, $password: String!) {
          userLoginEmail(email: $email, password: $password) {
            accessToken
          }
        }
      '''
      variables: {email, password}
    .then @afterLogin

  loginLink: ({userId, tokenStr} = {}) =>
    @exoid.call 'graphql',
      graphql: '''
        mutation UserLoginLink($userId: ID!, $tokenStr: String!) {
          userLoginLink(userId: $userId, tokenStr: $tokenStr) {
            accessToken
          }
        }
      '''
      variables: {userId, tokenStr}
    .then @afterLogin

  stream: ({graphql, variables}, options = {}) =>
    options = _pick options, [
      'isErrorable', 'clientChangesStream', 'ignoreCache', 'initialSortFn'
      'isStreamed', 'limit'
    ]
    @waitValidAuthCookie
    .switchMap =>
      @exoid.stream 'graphql', {graphql, variables}, options

  call: ({graphql, variables}, options = {}) =>
    {invalidateAll, invalidateSingle, additionalDataStream} = options

    unless graphql
      console.warn 'missing', arguments[0]

    @waitValidAuthCookie.take(1).toPromise()
    .then =>
      @exoid.call 'graphql', {graphql, variables}, {additionalDataStream}
    .then (response) =>
      if invalidateAll
        console.log 'Invalidating all'
        @exoid.invalidateAll()
      else if invalidateSingle
        console.log 'Invalidating single', invalidateSingle
        @exoid.invalidate invalidateSingle.path, invalidateSingle.body
      response
