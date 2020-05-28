# TODO: need to convert to graphql before this will work

export default class Subscription
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

  getAllByEntityId: (entityId) =>
    @auth.stream "#{@namespace}.getAllByEntityId", {entityId}
