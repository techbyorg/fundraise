/* eslint-disable
    no-unused-expressions,
    no-unused-vars,
*/
// TODO: This file was created by bulk-decaffeinate.
// Fix any style issues and re-enable lint.
import config from '../config'

export default class IrsOrg990 {
  constructor ({ auth }) { this.getAllByEin = this.getAllByEin.bind(this); this.getStatsByEin = this.getStatsByEin.bind(this); this.auth = auth; null }

  getAllByEin (ein) {
    return this.auth.stream(`${this.namespace}.getAllByEin`, { ein })
  }

  getStatsByEin (ein) {
    return this.auth.stream(`${this.namespace}.getStatsByEin`, { ein })
  }
}
