config = require '../config'

module.exports = class IrsContribution
  namespace: 'irsContributions'

  constructor: ({@auth}) -> null

  getAllByFromEin: (fromEin) =>
    @auth.stream
      query: '''
        query IrsContributionGetAllByFromEin($fromEin: String!) {
          irsContributions(fromEin: $fromEin) {
            nodes { fromEin, amount }
          }
        }
      '''
      variables: {fromEin}
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
