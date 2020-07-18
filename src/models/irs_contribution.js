export default class IrsContribution {
  constructor ({ auth }) {
    this.auth = auth
  }

  getAllByFromEin = (fromEin, { limit } = {}) => {
    return this.auth.stream({
      query: `
        query IrsContributionGetAllByFromEin($fromEin: String!, $limit: Int) {
          irsContributions(fromEin: $fromEin, limit: $limit) {
            nodes { year, toId, toName, toCity, toState, amount, nteeMajor, relationship, purpose }
          }
        }`,
      variables: { fromEin, limit },
      pull: 'irsContributions'
    })
  }

  getAllByToId = (toId, { limit } = {}) => {
    return this.auth.stream({
      query: `
        query IrsContributionGetAllByFromEin($toId: String!, $limit: Int) {
          irsContributions(toId: $toId, limit: $limit) {
            nodes {
              year, fromEin, toName, toCity, toState, amount, nteeMajor, relationship, purpose,
              irsFund { name, ein }
            }
          }
        }`,
      variables: { toId, limit },
      pull: 'irsContributions'
    })
  }

  search = ({ query, limit }) => {
    return this.auth.stream({
      query: 'query IrsContributionSearch($query: ESQuery!) { irsContributions(query: $query) { nodes { fromEin } } }',
      variables: { query },
      pull: 'irsContributions'
    })
  }
}
