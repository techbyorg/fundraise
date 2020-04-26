config = require '../config'

module.exports = class User
  namespace: 'users'

  constructor: ({@auth, @proxy, @exoid, @cookie, @l, @overlay, @portal}) -> null

  getMe: ({embed} = {}) =>
    @auth.stream
      graphql: '''
        query UserGetMe { me { id, name, data { bio } } }
      '''

  getById: (id) =>
    @auth.stream
      graphql: '''
        query UserGetById($id: ID!) { user(id: $id) { id, name, data { bio } } }
      '''
      variables: {id}

  getIp: =>
    @cookie.get 'ip'

  unsubscribeEmail: ({userId, tokenStr}) =>
    @auth.call
      graphql: '''
        mutation UserUnsubscribeEmail($userId: ID!, $tokenStr: String!) {
          userUnsubscribeEmail(userId: $userId, tokenStr: $tokenStr): Boolean
        }
      '''
      variables: {userId, tokenStr}

  verifyEmail: ({userId, tokenStr}) =>
    @auth.call
      graphql: '''
        mutation UserVerifyEmail($userId: ID!, $tokenStr: String!) {
          userVerifyEmail(userId: $userId, tokenStr: $tokenStr): Boolean
        }
      '''
      variables: {userId, tokenStr}

  resendVerficationEmail: =>
    @auth.call
      graphql: '''
        mutation UserResendVerficationEmail {
          userResendVerficationEmail: Boolean
        }
      '''

  upsert: (diff, {file} = {}) =>
    if file
      formData = new FormData()
      formData.append 'file', file, file.name

      @proxy config.API_URL + '/upload', {
        method: 'post'
        query:
          path: 'graphql'
          body: JSON.stringify {
            graphql: '''
              mutation UserUpsert($diff UserInput!) {
                userUpsert($diff) {
                  user {
                    id # FIXME: fragment?
                    name
                    email
                  }
                }
              }
            '''
            variables: {input: diff}
          }
        body: formData
      }
      # this (exoid.update) doesn't actually work... it'd be nice
      # but it doesn't update existing streams
      # .then @exoid.update
      .then (response) =>
        setTimeout @exoid.invalidateAll, 0
        response
    else
      @auth.call
        graphql: '''
          mutation UserUpsert($diff UserInput!) {
            userUpsert($diff) {
              user {
                id # FIXME: fragment?
                name
                email
              }
            }
          }
        '''
        variables: {input: diff}
      , {invalidateAll: true}

  getDisplayName: (user) =>
    user?.name or @l.get 'general.anonymous'

  isMember: (user) ->
    Boolean user?.email

  # requestLoginIfGuest: (user) =>
  #   new Promise (resolve, reject) =>
  #     if @isMember user
  #       resolve true
  #     else
  #       @overlay.open new SignInOverlay({
  #         model: {@l, @auth, @overlay, @portal, user: this}
  #       }), {
  #         data: 'join'
  #         onComplete: resolve
  #         onCancel: reject
  #       }
