/* eslint-disable
    no-unused-expressions,
    no-unused-vars,
*/
// TODO: This file was created by bulk-decaffeinate.
// Fix any style issues and re-enable lint.
import config from '../config'

export default class IrsFund990 {
  constructor ({ auth }) { this.auth = auth; null }

  getAllByEin (ein) {
    return this.auth.stream({
      query: `\
query IrsFund990GetAllByEin($ein: String!) {
  irsFund990s(ein: $ein) {
    nodes { ein, year, taxPeriod }
  }
}\
`,
      variables: { ein },
      pull: 'irsFund990s'
    })
  }
}
