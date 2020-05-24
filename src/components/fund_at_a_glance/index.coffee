{z, classKebab, useStream} = require 'zorium'

FormatService = require '../../services/format'

if window?
  require './index.styl'

module.exports = $fundAtAGlance = (props) ->
  {model, router, placeholderNameStream, irsFund} = props

  {placeholderName} = useStream ->
    placeholderName: placeholderNameStream

  z '.z-fund-at-a-glance',
    z '.name', irsFund?.name or placeholderName
    z '.top-metrics',
      z '.metric',
        z '.value',
          FormatService.abbreviateDollar irsFund?.lastYearStats?.grantSum
        z '.name',
          model.l.get 'fund.grantsPerYear'
      z '.metric',
        z '.value',
          FormatService.abbreviateDollar irsFund?.assets
        z '.name',
          model.l.get 'org.assets'

    z '.block',
      z '.title', model.l.get 'general.location'
      z '.text', FormatService.location irsFund

    z '.block',
      z '.title', model.l.get 'fund.focusAreas'
      z '.text',
        # FIXME
        model.l.get "nteeMajor.#{irsFund?.nteecc?.substr(0, 1)}"

    if irsFund?.website
      z '.block',
        z '.title', model.l.get 'general.web'
        router.link z 'a.text.link', {
          href: irsFund?.website
        },
          irsFund?.website

    if irsFund?.lastYearStats
      z '.block',
        z '.title',
          model.l.get 'org.lastReport', {
            replacements: {year: irsFund.lastYearStats.year}
          }
        z '.metrics',
          z '.metric',
            z '.value',
              FormatService.abbreviateDollar irsFund.lastYearStats.expenses
            z '.name',
              model.l.get 'metric.expenses'
          z '.metric',
            z '.value',
              FormatService.abbreviateDollar irsFund.lastYearStats.revenue
            z '.name',
              model.l.get 'metric.revenue'
