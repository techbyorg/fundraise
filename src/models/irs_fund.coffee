config = require '../config'

module.exports = class IrsFund
  namespace: 'irsFunds'

  constructor: ({@auth}) -> null

  getByEin: (ein) =>
    @auth.stream
      query: '''
        query IrsFundGetByEin($ein: String!) {
          irsFund(ein: $ein) {
            name, ein
          }
        }
      '''
      variables: {ein}
      pull: 'irsFund'

  search: ({query, limit}) =>
    @auth.stream
      query: '''
        query IrsFundSearch($query: JSON!, $limit: Int) {
          irsFunds(query: $query, limit: $limit) {
            nodes { name, ein }
          }
        }
      '''
      variables: {query, limit}
      pull: 'irsFunds'
    , {ignoreCache: true}
