// TODO: need to convert to graphql before this will work

export default class PushToken {
  constructor ({ auth, token }) {
    this.auth = auth
    this.token = token
  }

  upsert = ({ tokenStr, sourceType, deviceId } = {}) => {
    return this.auth.call(`${this.namespace}.upsert`, { tokenStr, sourceType, deviceId })
  }

  setCurrentPushToken = (token) => {
    return this.token.next(token)
  }

  getCurrentPushToken = () => {
    return this.token
  }
}
