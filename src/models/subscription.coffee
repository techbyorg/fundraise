module.exports = class Subscription
  namespace: 'subscriptions'

  constructor: ({@auth}) -> null

  subscribe: ({entityId, sourceType, sourceId, isTopic}) =>
    @auth.call "#{@namespace}.subscribe", {
      entityId, sourceType, sourceId, isTopic
    }

  unsubscribe: ({entityId, sourceType, sourceId, isTopic}) =>
    @auth.call "#{@namespace}.unsubscribe", {
      entityId, sourceType, sourceId, isTopic
    }, {invalidateAll: true}

  sync: ({entityId}) =>
    @auth.call "#{@namespace}.sync", {entityId}, {invalidateAll: true}

  getAllByEntityId: (entityId) =>
    @auth.stream "#{@namespace}.getAllByEntityId", {entityId}
