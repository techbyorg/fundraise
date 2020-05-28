import config from '../config'

export default class IrsFund
  constructor: ({@auth}) -> null

  getByEin: (ein) =>
    @auth.stream
      query: '''
        query IrsFundGetByEin($ein: String!) {
          irsFund(ein: $ein) {
            ein, name, city, state, assets, mission, website,
            yearlyStats {
              years { year, assets }
            },
            lastYearStats {
              grants, grantMedian, grantSum, revenue, expenses
            },
            applicantInfo {
              acceptsUnsolicitedRequests, recipientName,
              requirements, deadlines, restrictions,
              address {
                street1, street2, postalCode, city, state, countryCode
              }
            }
            fundedNteeMajors { key, count, percent, sum, sumPercent }
            fundedStates { key, count, percent, sum, sumPercent }
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
              fundedNteeMajors { key, count }
            }
          }
        }
      '''
      variables: {query, limit}
      pull: 'irsFunds'
    , {ignoreCache: true}
