import config from '../config'

export default class IrsOrg
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
        query IrsOrgSearch($query: ESQuery!) {
          irsOrgs(query: $query) {
            nodes { name, ein }
          }
        }
      '''
      variables: {query}
      pull: 'irsOrgs'

  isEin: (str) ->
    !isNaN parseInt(str)
