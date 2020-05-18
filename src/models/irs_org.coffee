config = require '../config'

module.exports = class IrsOrg
  namespace: 'irsOrgs'

  constructor: ({@auth}) -> null

  getByEin: (ein) =>
    @auth.stream
      query: '''
        query IrsOrgGetByEin($ein: String!) {
          irsOrg(ein: $ein) {
            name, ein, employeeCount, assets
          }
      }
      '''
      variables: {ein}
      pull: 'irsOrg'

  search: ({query, limit}) =>
    @auth.stream
      query: '''
        query IrsOrgSearch($query: JSON!) {
          irsOrgs(query: $query) {
            nodes { name, ein }
          }
        }
      '''
      variables: {query}
      pull: 'irsOrgs'
    , {ignoreCache: true}
