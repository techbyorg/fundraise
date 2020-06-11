/* eslint-disable
    no-unused-expressions,
*/
// TODO: This file was created by bulk-decaffeinate.
// Fix any style issues and re-enable lint.
// TODO: need to convert to graphql before this will work

let UserData
export default UserData = (function () {
  UserData = class UserData {
    static initClass () {
      this.prototype.namespace = 'userData'
    }

    constructor ({ auth }) { this.getByMe = this.getByMe.bind(this); this.getByUserId = this.getByUserId.bind(this); this.upsert = this.upsert.bind(this); this.auth = auth; null }

    getByMe () {
      return this.auth.stream(`${this.namespace}.getByMe`, {})
    }

    getByUserId () {
      return this.auth.stream(`${this.namespace}.getByUserId`, {})
    }

    upsert (userData) {
      return this.auth.call(`${this.namespace}.upsert`, userData, { invalidateAll: true })
    }
  }
  UserData.initClass()
  return UserData
})()
