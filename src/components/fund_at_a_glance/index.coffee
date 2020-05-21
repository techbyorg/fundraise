{z, classKebab, useMemo, useStream} = require 'zorium'

FormatService = require '../../services/format'

if window?
  require './index.styl'

module.exports = FundAtAGlance = ({model, irsFund}) ->
  console.log 'fund', irsFund
  z '.z-fund-at-a-glance',
    z '.name', irsFund?.name
    z '.top-metrics',
      z '.metric',
        z '.value',
          FormatService.number irsFund?.employeeCount or 0
        z '.name',
          model.l.get 'org.employees'
      z '.metric',
        z '.value',
          '$'
          FormatService.number irsFund?.assets
        z '.name',
          model.l.get 'org.assets'
    z '.block',
      z '.title', model.l.get 'general.location'
      z '.text', FormatService.location irsFund
    z '.block',
      z '.title', model.l.get 'general.category'
      z '.text',
        model.l.get "nteeMajor.#{irsFund?.nteecc?.substr(0, 1)}"
    z '.block',
      z '.title', model.l.get 'general.mission'
      z '.text.mission', {
        className: classKebab {
          isTruncated: irsFund?.mission?.length > 50
        }
      },
        irsFund?.mission
    # z '.block',
    #   z '.title',
    #     model.l.get 'org.lastReport', {
    #       replacements: {year: irsFund990Stats?.last?.year}
    #     }
    #   z '.metrics',
    #     z '.metric',
    #       z '.value',
    #         '$'
    #         FormatService.number irsFund990Stats?.last?.expenses
    #       z '.name',
    #         model.l.get 'metric.expenses'
    #     z '.metric',
    #       z '.value',
    #         '$'
    #         FormatService.number irsFund990Stats?.last?.revenue
    #       z '.name',
    #         model.l.get 'metric.revenue'
