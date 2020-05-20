config = require '../config'

module.exports = class IrsPerson
  namespace: 'irsPersons'

  constructor: ({@auth}) -> null

  getAllByEin: (ein) =>
    @auth.stream
      query: '''
        query IrsPersonGetAllByEin($ein: String!) {
          irsPersons(ein: $ein) {
            nodes { name, ein }
          }
        }
      '''
      variables: {ein}
      pull: 'irsPersons'
    , {ignoreCache: true}


  search: ({query, limit}) =>
    @auth.stream
      query: '''
        query IrsPersonSearch($query: JSON!) { irsPersons(query: $query) { nodes { name, ein } } }
      '''
      variables: {query}
      pull: 'irsPersons'
    , {ignoreCache: true}
