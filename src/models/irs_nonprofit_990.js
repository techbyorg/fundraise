export default class IrsNonprofit990 {
  constructor ({ auth }) {
    this.auth = auth
  }

  getAllByEin (ein) {
    return this.auth.stream({
      query: `
        query IrsNonprofit990GetAllByEin($ein: String!) {
          irsNonprofit990s(ein: $ein) {
            nodes { ein, year, taxPeriod }
          }
        }`,
      variables: { ein },
      pull: 'irsNonprofit990s'
    })
  }
}
