/* eslint-disable
    no-unused-expressions,
    no-unused-vars,
*/
// TODO: This file was created by bulk-decaffeinate.
// Fix any style issues and re-enable lint.
import config from '../config'

export default class IrsOrg {
  constructor ({ auth }) { this.getByEin = this.getByEin.bind(this); this.search = this.search.bind(this); this.auth = auth; null }

  getByEin (ein) {
    return this.auth.stream({
      query: `\
  query IrsOrgGetByEin($ein: String!) {
    irsOrg(ein: $ein) {
      name, ein, employeeCount, assets
    }
}\
`,
      variables: { ein },
      pull: 'irsOrg'
    })
  }

  search ({ query, limit }) {
    return this.auth.stream({
      query: `\
query IrsOrgSearch($query: ESQuery!) {
  irsOrgs(query: $query) {
    nodes { name, ein }
  }
}\
`,
      variables: { query },
      pull: 'irsOrgs'
    })
  }

  isEin (str) {
    return !isNaN(parseInt(str))
  }
}
