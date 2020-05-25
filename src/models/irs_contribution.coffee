config = require '../config'

module.exports = class IrsContribution
  constructor: ({@auth}) -> null

  getAllByFromEin: (fromEin, {limit} = {}) =>
    @auth.stream
      query: '''
        query IrsContributionGetAllByFromEin($fromEin: String!, $limit: Int) {
          irsContributions(fromEin: $fromEin, limit: $limit) {
            nodes { year, toId, toName, toCity, toState, amount, nteeMajor, relationship, purpose }
          }
        }
      '''
      variables: {fromEin, limit}
      pull: 'irsContributions'
    , {ignoreCache: true}


  getAllByToId: (toId, {limit} = {}) =>
    @auth.stream
      query: '''
        query IrsContributionGetAllByFromEin($toId: String!, $limit: Int) {
          irsContributions(toId: $toId, limit: $limit) {
            nodes { year, fromEin, toName, toCity, toState, amount, nteeMajor, relationship, purpose }
          }
        }
      '''
      variables: {toId, limit}
      pull: 'irsContributions'
    , {ignoreCache: true}


  search: ({query, limit}) =>
    @auth.stream
      query: '''
        query IrsContributionSearch($query: JSON!) { irsContributions(query: $query) { nodes { fromEin } } }
      '''
      variables: {query}
      pull: 'irsContributions'
    , {ignoreCache: true}
