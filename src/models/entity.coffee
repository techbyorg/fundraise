DEFAULT_FIELDS = "id, slug"

export default class Entity
  namespace: 'entities'

  constructor: ({@auth}) -> null

  getAll: =>
    @auth.stream
      query: """
        query EntityGetAll { entities { #{DEFAULT_FIELDS} }
      """

  getAllByUserId: (userId) =>
    @auth.stream
      query: """
        query EntityGetallByUserId($userId: ID!) {
          entities(userId: $userId) {
            #{DEFAULT_FIELDS}
          }
        }
      """
      variables: {userId}

  getById: (id) =>
    @auth.stream
      query: """
        query EntityGetById($slug: ID!) { entity(id: $id) { #{DEFAULT_FIELDS} }
      """
      variables: {id}

  getBySlug: (slug) =>
    @auth.stream
      query: """
        query EntityGetBySlug($slug: String!) { entity(slug: $slug) { #{DEFAULT_FIELDS} }
      """
      variables: {slug}

  getDefaultEntity: =>
    @auth.stream
      query: """
        query EntityGetDefault { entity { #{DEFAULT_FIELDS} } }
      """

  joinById: (id) =>
    @auth.call {
      query: "
        mutation EntityJoinById($id: ID!) {
          entityJoinById(id: $id: entity { #{DEFAULT_FIELDS} }
        }
      "
      variables: {id}
    }, {invalidateAll: true}

  leaveById: (id) =>
    @auth.call {
      query: "
        mutation EntityLeaveById($id: ID!) {
          entityLeaveById(id: $id: entity { #{DEFAULT_FIELDS} }
        }
      "
      variables: {id}
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
