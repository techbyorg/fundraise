// TODO: need to convert to graphql before this will work

export default class UserData {
  constructor ({ auth }) {
    this.auth = auth
  }

  getByMe = () => {
    return this.auth.stream(`${this.namespace}.getByMe`, {})
  }

  getByUserId = () => {
    return this.auth.stream(`${this.namespace}.getByUserId`, {})
  }

  upsert = (userData) => {
    return this.auth.call(`${this.namespace}.upsert`, userData, { invalidateAll: true })
  }
}
