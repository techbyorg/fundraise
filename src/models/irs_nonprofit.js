export default class IrsNonprofit {
  constructor ({ auth }) {
    this.getByEin = this.getByEin.bind(this)
    this.search = this.search.bind(this)
    this.auth = auth
  }

  getByEin (ein) {
    return this.auth.stream({
      query: `
        query IrsNonprofitGetByEin($ein: String!) {
          irsNonprofit(ein: $ein) {
            ein, name, city, state, assets, mission, website,
            employeeCount, volunteerCount,
            yearlyStats {
              years { year, assets, employeeCount, volunteerCount }
            },
          }
        }`,
      variables: { ein },
      pull: 'irsNonprofit'
    })
  }

  search ({ query, sort, limit }) {
    return this.auth.stream({
      query: `
        query IrsNonprofitSearch($query: ESQuery!, $sort: JSON, $limit: Int) {
          irsNonprofits(query: $query, sort: $sort, limit: $limit) {
            totalCount,
            nodes {
              ein, nteecc, name, city, state, assets,
              employeeCount, volunteerCount
            }
          }
        }`,
      variables: { query, sort, limit },
      pull: 'irsNonprofits'
    })
  }

  isEin (str) {
    return !isNaN(parseInt(str))
  }
}
