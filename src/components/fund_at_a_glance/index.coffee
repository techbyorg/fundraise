{z, classKebab, useContext, useStream} = require 'zorium'

FormatService = require '../../services/format'
context = require '../../context'

if window?
  require './index.styl'

module.exports = $fundAtAGlance = (props) ->
  {placeholderNameStream, irsFund} = props
  {lang, router} = useContext context

  {placeholderName} = useStream ->
    placeholderName: placeholderNameStream

  z '.z-fund-at-a-glance',
    z '.name', irsFund?.name or placeholderName
    z '.top-metrics',
      z '.metric',
        z '.value',
          FormatService.abbreviateDollar irsFund?.lastYearStats?.grantSum
        z '.name',
          lang.get 'fund.grantsPerYear'
      z '.metric',
        z '.value',
          FormatService.abbreviateDollar irsFund?.assets
        z '.name',
          lang.get 'org.assets'

    z '.block',
      z '.title', lang.get 'general.location'
      z '.text', FormatService.location irsFund

    z '.block',
      z '.title', lang.get 'fund.focusAreas'
      z '.text',
        # FIXME
        lang.get "nteeMajor.#{irsFund?.nteecc?.substr(0, 1)}"

    if irsFund?.website
      z '.block',
        z '.title', lang.get 'general.web'
        router.link z 'a.text.link', {
          href: irsFund?.website
        },
          irsFund?.website

    if irsFund?.lastYearStats
      z '.block',
        z '.title',
          lang.get 'org.lastReport', {
            replacements: {year: irsFund.lastYearStats.year}
          }
        z '.metrics',
          z '.metric',
            z '.value',
              FormatService.abbreviateDollar irsFund.lastYearStats.expenses
            z '.name',
              lang.get 'metric.expenses'
          z '.metric',
            z '.value',
              FormatService.abbreviateDollar irsFund.lastYearStats.revenue
            z '.name',
              lang.get 'metric.revenue'
