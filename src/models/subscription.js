/* eslint-disable
    no-unused-expressions,
*/
// TODO: This file was created by bulk-decaffeinate.
// Fix any style issues and re-enable lint.
// TODO: need to convert to graphql before this will work

let Subscription
export default Subscription = (function () {
  Subscription = class Subscription {
    static initClass () {
      this.prototype.namespace = 'subscriptions'
    }

    constructor ({ auth }) { this.subscribe = this.subscribe.bind(this); this.unsubscribe = this.unsubscribe.bind(this); this.getAllByEntityId = this.getAllByEntityId.bind(this); this.auth = auth; null }

    subscribe ({ entityId, sourceType, sourceId, isTopic }) {
      return this.auth.call(`${this.namespace}.subscribe`, {
        entityId, sourceType, sourceId, isTopic
      })
    }

    unsubscribe ({ entityId, sourceType, sourceId, isTopic }) {
      return this.auth.call(`${this.namespace}.unsubscribe`, {
        entityId, sourceType, sourceId, isTopic
      }, { invalidateAll: true })
    }

    getAllByEntityId (entityId) {
      return this.auth.stream(`${this.namespace}.getAllByEntityId`, { entityId })
    }
  }
  Subscription.initClass()
  return Subscription
})()
