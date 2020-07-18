export default class IrsPerson {
  constructor ({ auth }) {
    this.auth = auth
  }

  getAllByEin = (ein) => {
    return this.auth.stream({
      query: `
        query IrsPersonGetAllByEin($ein: String!) {
          irsPersons(ein: $ein) {
            nodes { name, years { title, compensation, year } }
          }
        }`,
      variables: { ein },
      pull: 'irsPersons'
    })
  }

  search = ({ query, limit }) => {
    return this.auth.stream({
      query: `
        query IrsPersonSearch($query: ESQuery!) {
          irsPersons(query: $query) {
            nodes {
              name
            }
          }
        }`,
      variables: { query },
      pull: 'irsPersons'
    })
  }
}
