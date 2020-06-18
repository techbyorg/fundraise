export default class IrsOrg990 {
  constructor ({ auth }) {
    this.auth = auth
  }

  getAllByEin (ein) {
    return this.auth.stream({
      query: `
        query IrsOrg990GetAllByEin($ein: String!) {
          irsOrg990s(ein: $ein) {
            nodes { ein, year, taxPeriod }
          }
        }`,
      variables: { ein },
      pull: 'irsOrg990s'
    })
  }
}
