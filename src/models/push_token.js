/* eslint-disable
    no-unused-expressions,
*/
// TODO: This file was created by bulk-decaffeinate.
// Fix any style issues and re-enable lint.
// TODO: need to convert to graphql before this will work

export default class PushToken {
  constructor ({ auth, token }) { this.upsert = this.upsert.bind(this); this.setCurrentPushToken = this.setCurrentPushToken.bind(this); this.getCurrentPushToken = this.getCurrentPushToken.bind(this); this.auth = auth; this.token = token; null }

  upsert ({ tokenStr, sourceType, deviceId } = {}) {
    return this.auth.call(`${this.namespace}.upsert`, { tokenStr, sourceType, deviceId })
  }

  setCurrentPushToken (token) {
    return this.token.next(token)
  }

  getCurrentPushToken () {
    return this.token
  }
}
