/* eslint-disable
    no-unused-expressions,
*/
// TODO: This file was created by bulk-decaffeinate.
// Fix any style issues and re-enable lint.
// TODO: need to convert to graphql before this will work

let UserSettings
export default UserSettings = (function () {
  UserSettings = class UserSettings {
    static initClass () {
      this.prototype.namespace = 'userSettings'
    }

    constructor ({ auth }) { this.getByMe = this.getByMe.bind(this); this.upsert = this.upsert.bind(this); this.auth = auth; null }

    getByMe () {
      return this.auth.stream(`${this.namespace}.getByMe`, {})
    }

    upsert (userSettings) {
      return this.auth.call(`${this.namespace}.upsert`, userSettings, { invalidateAll: true })
    }
  }
  UserSettings.initClass()
  return UserSettings
})()
