SignInOverlay = require '../components/sign_in_overlay'
config = require '../config'

module.exports = class User
  namespace: 'users'

  constructor: ({@auth, @proxy, @exoid, @cookie, @l, @overlay, @portal}) -> null

  getMe: ({embed} = {}) =>
    @auth.stream "#{@namespace}.getMe", {embed}

  getIp: =>
    @cookie.get 'ip'

  getCountry: =>
    @auth.stream "#{@namespace}.getCountry"

  getById: (id, {embed} = {}) =>
    @auth.stream "#{@namespace}.getById", {id, embed}

  search: ({query, limit}) =>
    @auth.stream "#{@namespace}.search", {query, limit}

  getReferrer: =>
    @auth.stream "#{@namespace}.getReferrer", {}

  setReferrer: (referrer) =>
    @auth.call "#{@namespace}.setReferrer", {referrer}

  unsubscribeEmail: ({userId, tokenStr}) =>
    @auth.call "#{@namespace}.unsubscribeEmail", {userId, tokenStr}

  verifyEmail: ({userId, tokenStr}) =>
    @auth.call "#{@namespace}.verifyEmail", {userId, tokenStr}

  resendVerficationEmail: =>
    @auth.call "#{@namespace}.resendVerficationEmail", {}

  upsert: (userDiff, {file} = {}) =>
    if file
      formData = new FormData()
      formData.append 'file', file, file.name

      @proxy config.API_URL + '/upload', {
        method: 'post'
        query:
          path: "#{@namespace}.upsert"
          body: JSON.stringify {userDiff}
        body: formData
      }
      # this (exoid.update) doesn't actually work... it'd be nice
      # but it doesn't update existing streams
      # .then @exoid.update
      .then (response) =>
        setTimeout @exoid.invalidateAll, 0
        response
    else
      @auth.call "#{@namespace}.upsert", {userDiff}, {invalidateAll: true}

  getDisplayName: (user) =>
    user?.name or @l.get 'general.anonymous'

  isMember: (user) ->
    Boolean user?.email

  requestLoginIfGuest: (user) =>
    new Promise (resolve, reject) =>
      if @isMember user
        resolve true
      else
        @overlay.open new SignInOverlay({
          model: {@l, @auth, @overlay, @portal, user: this}
        }), {
          data: 'join'
          onComplete: resolve
          onCancel: reject
        }
