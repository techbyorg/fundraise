export default class Notification {
  constructor ({ auth }) {
    this.auth = auth
  }

  getAll = () => {
    return this.auth.stream(`${this.namespace}.getAll`, {})
  }

  getUnreadCount = () => {
    return this.auth.stream(`${this.namespace}.getUnreadCount`, {})
  }
}
