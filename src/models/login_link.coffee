module.exports = class LoginLink
  namespace: 'loginLinks'

  constructor: ({@auth}) -> null

  getByUserIdAndToken: (userId, tokenStr) =>
    @auth.stream "#{@namespace}.getByUserIdAndTokenStr", {userId, tokenStr}
