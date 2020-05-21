config = require '../config'

module.exports = class IrsFund
  namespace: 'irsFunds'

  constructor: ({@auth}) -> null

  getByEin: (ein) =>
    @auth.stream
      query: '''
        query IrsFundGetByEin($ein: String!) {
          irsFund(ein: $ein) {
            ein, name, assets, mission, website,
            lastYearStats {grants, grantMedian},
            fundedNteeMajors
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
            nodes { name, assets, ein }
          }
        }
      '''
      variables: {query, limit}
      pull: 'irsFunds'
    , {ignoreCache: true}
