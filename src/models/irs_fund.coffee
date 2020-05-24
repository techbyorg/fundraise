config = require '../config'

module.exports = class IrsFund
  namespace: 'irsFunds'

  constructor: ({@auth}) -> null

  getByEin: (ein) =>
    @auth.stream
      query: '''
        query IrsFundGetByEin($ein: String!) {
          irsFund(ein: $ein) {
            ein, name, city, state, assets, mission, website,
            contributionStats, yearlyStats,
            lastYearStats {
              grants, grantMedian, grantSum, revenue, expenses
              },
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
            totalCount,
            nodes {
              ein, name, city, state, assets,
              lastYearStats {
                grants, grantMedian, grantSum
              }
            }
          }
        }
      '''
      variables: {query, limit}
      pull: 'irsFunds'
    , {ignoreCache: true}
