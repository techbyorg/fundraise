{z, useContext} = require 'zorium'

import FormatService from 'frontend-shared/services/format'

import context from '../../context'

if window?
  require './index.styl'

module.exports = $fundSearchResultsMobileRow = ({row}) ->
  {lang} = useContext context

  z '.z-fund-search-results-mobile-row',
    z '.name', row.name
    z '.location', FormatService.location row
    # z '.focus-areas'
    z '.stats',
      z '.stat',
        z '.title', lang.get 'org.assets'
        z '.value',
          FormatService.abbreviateDollar row.assets
      z '.stat',
        z '.title', lang.get 'fund.medianGrant'
        z '.value',
          FormatService.abbreviateDollar row.lastYearStats?.grantMedian
      z '.stat',
        z '.title', lang.get 'fund.grantsPerYear'
        z '.value',
          FormatService.abbreviateDollar row.lastYearStats?.grantSum
