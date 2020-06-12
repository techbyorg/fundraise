export default class Notification {
  constructor ({ auth }) {
    this.getAll = this.getAll.bind(this)
    this.getUnreadCount = this.getUnreadCount.bind(this)
    this.auth = auth
  }

  getAll () {
    return this.auth.stream(`${this.namespace}.getAll`, {})
  }

  getUnreadCount () {
    return this.auth.stream(`${this.namespace}.getUnreadCount`, {})
  }
}
