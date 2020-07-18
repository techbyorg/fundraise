// TODO: need to convert to graphql before this will work

export default class UserSettings {
  constructor ({ auth }) {
    this.auth = auth
  }

  getByMe = () => {
    return this.auth.stream(`${this.namespace}.getByMe`, {})
  }

  upsert = (userSettings) => {
    return this.auth.call(`${this.namespace}.upsert`, userSettings, { invalidateAll: true })
  }
}
