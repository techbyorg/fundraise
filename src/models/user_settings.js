// TODO: need to convert to graphql before this will work

export default class UserSettings {
  constructor ({ auth }) {
    this.getByMe = this.getByMe.bind(this)
    this.upsert = this.upsert.bind(this)
    this.auth = auth
  }

  getByMe () {
    return this.auth.stream(`${this.namespace}.getByMe`, {})
  }

  upsert (userSettings) {
    return this.auth.call(`${this.namespace}.upsert`, userSettings, { invalidateAll: true })
  }
}
