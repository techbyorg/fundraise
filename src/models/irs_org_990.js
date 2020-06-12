export default class IrsOrg990 {
  constructor ({ auth }) {
    this.getAllByEin = this.getAllByEin.bind(this)
    this.getStatsByEin = this.getStatsByEin.bind(this)
    this.auth = auth
  }

  getAllByEin (ein) {
    return this.auth.stream(`${this.namespace}.getAllByEin`, { ein })
  }

  getStatsByEin (ein) {
    return this.auth.stream(`${this.namespace}.getStatsByEin`, { ein })
  }
}
