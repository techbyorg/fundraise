config = require '../config'

module.exports = class IrsPerson
  namespace: 'irsPersons'

  constructor: ({@auth}) -> null

  getAllByEin: (ein) =>
    @auth.stream "#{@namespace}.getAllByEin", {ein}

  search: ({query, limit}) =>
    @auth.stream
      query: '''
        query IrsPersonSearch($query: JSON!) { irsPersons(query: $query) { nodes { name, ein } } }
      '''
      variables: {query}
      pull: 'irsPerson'
    , {ignoreCache: true}
