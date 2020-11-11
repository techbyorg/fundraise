import _ from 'lodash'

class RouterService {
  // FIXME: this should be in fundraise repo, not frontend-shared
  getFund = (fund, tab, router) => {
    if (tab) {
      return router.get('fundByEinWithTab', {
        tab, slug: _.kebabCase(fund?.name), ein: fund?.ein
      })
    } else {
      return router.get('fundByEin', { slug: _.kebabCase(fund?.name), ein: fund?.ein })
    }
  }

  goFund = (fund, router) => {
    return router.goPath(this.getFund(fund, null, router))
  }

  getNonprofit = (nonprofit, tab, router) => {
    if (tab) {
      return router.get('nonprofitByEinWithTab', {
        tab, slug: _.kebabCase(nonprofit?.name), ein: nonprofit?.ein
      })
    } else {
      return router.get('nonprofitByEin', { slug: _.kebabCase(nonprofit?.name), ein: nonprofit?.ein })
    }
  }

  goNonprofit = (nonprofit, router) => {
    return router.goPath(this.getNonprofit(nonprofit, null, router))
  }
}

export default RouterService
