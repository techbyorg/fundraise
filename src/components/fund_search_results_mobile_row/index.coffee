{z} = require 'zorium'

FormatService = require '../../services/format'

if window?
  require './index.styl'

module.exports = $fundSearchResultsMobileRow = ({model, row}) ->
  z '.z-fund-search-results-mobile-row',
    z '.name', row.name
    z '.location', FormatService.location row
    # z '.focus-areas'
    z '.stats',
      z '.stat',
        z '.title', model.l.get 'org.assets'
        z '.value',
          FormatService.abbreviateDollar row.assets
      z '.stat',
        z '.title', model.l.get 'fund.medianGrant'
        z '.value',
          FormatService.abbreviateDollar row.lastYearStats?.grantMedian
      z '.stat',
        z '.title', model.l.get 'fund.grantsPerYear'
        z '.value',
          FormatService.abbreviateDollar row.lastYearStats?.grantSum
