module.exports = class PushToken
  namespace: 'pushTokens'

  constructor: ({@auth, @pushToken}) -> null

  upsert: ({tokenStr, sourceType, deviceId} = {}) =>
    @auth.call "#{@namespace}.upsert", {tokenStr, sourceType, deviceId}

  setCurrentPushToken: (pushToken) =>
    @pushToken.next pushToken

  getCurrentPushToken: =>
    @pushToken
