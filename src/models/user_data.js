// TODO: need to convert to graphql before this will work

export default class UserData {
  constructor ({ auth }) {
    this.getByMe = this.getByMe.bind(this)
    this.getByUserId = this.getByUserId.bind(this)
    this.upsert = this.upsert.bind(this)
    this.auth = auth
  }

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
