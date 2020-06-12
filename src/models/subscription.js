// TODO: need to convert to graphql before this will work

export default class Subscription {
  constructor ({ auth }) {
    this.subscribe = this.subscribe.bind(this)
    this.unsubscribe = this.unsubscribe.bind(this)
    this.getAllByEntityId = this.getAllByEntityId.bind(this)
    this.auth = auth
  }

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
