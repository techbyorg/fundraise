module.exports = class Entity
  namespace: 'entities'

  constructor: ({@auth}) -> null

  create: ({name, description, mode}) =>
    @auth.call "#{@namespace}.create", {
      name, description, mode
    }, {invalidateAll: true}

  onboard: ({ein, type}) =>
    @auth.call "#{@namespace}.onboard", {
      ein, type
    }, {invalidateAll: true}

  getAll: ({filter, language, embed} = {}) =>
    embed ?= ['channels', 'userCount']
    @auth.stream "#{@namespace}.getAll", {filter, language, embed}

  getAllByUserId: (userId, {embed} = {}) =>
    embed ?= ['meEntityUser', 'channels', 'userCount']
    @auth.stream "#{@namespace}.getAllByUserId", {userId, embed}

  getById: (id, {autoJoin} = {}) =>
    @auth.stream "#{@namespace}.getById", {id, autoJoin}

  getBySlug: (slug, {autoJoin} = {}) =>
    @auth.stream "#{@namespace}.getBySlug", {slug, autoJoin}

  getDefaultEntity: ({autoJoin} = {}) =>
    @auth.stream "#{@namespace}.getDefault", {autoJoin}

  getAllConversationsById: (id) =>
    @auth.stream "#{@namespace}.getAllConversationsById", {id}

  joinById: (id) =>
    @auth.call "#{@namespace}.joinById", {id}, {
      invalidateAll: true
    }

  leaveById: (id) =>
    @auth.call "#{@namespace}.leaveById", {id}, {
      invalidateAll: true
    }

  inviteById: (id, {userIds}) =>
    @auth.call "#{@namespace}.inviteById", {id, userIds}, {invalidateAll: true}

  sendNotificationById: (id, {title, description, pathKey}) =>
    @auth.call "#{@namespace}.sendNotificationById", {
      id, title, description, pathKey
      }, {invalidateAll: true}

  updateById: (id, {name, description, mode}) =>
    @auth.call "#{@namespace}.updateById", {
      id, name, description, mode
    }, {invalidateAll: true}

  getDisplayName: (entity) ->
    entity?.name or 'Nameless'

  getPath: (entity, key, {replacements, router, language}) ->
    unless router
      return '/'
    subdomain = router.getSubdomain()

    replacements ?= {}
    replacements.entityId = entity?.slug or entity?.id

    path = router.get key, replacements, {language}
    if subdomain is entity?.slug
      path = path.replace "/#{entity?.slug}", ''
    path

  goPath: (entity, key, {replacements, router, language}, options) ->
    subdomain = router.getSubdomain()

    replacements ?= {}
    replacements.entityId = entity?.slug or entity?.id

    path = router.get key, replacements, {language}
    if subdomain is entity?.slug
      path = path.replace "/#{entity?.slug}", ''
    router.goPath path, options
