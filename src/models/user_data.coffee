# TODO: need to convert to graphql before this will work

export default class UserData
  namespace: 'userData'

  constructor: ({@auth}) -> null

  getByMe: =>
    @auth.stream "#{@namespace}.getByMe", {}

  getByUserId: =>
    @auth.stream "#{@namespace}.getByUserId", {}

  upsert: (userData) =>
    @auth.call "#{@namespace}.upsert", userData, {invalidateAll: true}
