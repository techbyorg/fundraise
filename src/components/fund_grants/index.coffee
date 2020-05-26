{z, useMemo, useStream} = require 'zorium'
_map = require 'lodash/map'

$table = require '../table'
FormatService = require '../../services/format'

if window?
  require './index.styl'

module.exports = $fundGrants = ({model, router, irsFund, irsFundStream}) ->
  {contributionsStream} = useMemo ->
    {
      contributionsStream: irsFundStream.switchMap (irsFund) ->
        model.irsContribution.getAllByFromEin irsFund.ein, {limit: 100}
    }
  , []

  {contributions} = useStream ->
    contributions: contributionsStream

  z '.z-fund-grants',
    z '.grants',
      z $table,
        model: model
        router: router
        data: contributions?.nodes
        mobileRowRenderer: $fundGrantsMobileRow
        columns: [
          {
            key: 'amount', name: model.l.get('general.amount'), width: 150
            content: ({row}) ->
              "$#{FormatService.number row.amount}"
          }
          {
            key: 'toId', name: 'Name', width: 300
            content: $fundGrantName
          }
          {
            key: 'purpose', name: model.l.get('fundGrants.purpose'), width: 300, isFlex: true
            content: ({row}) ->
              z '.purpose',
                z '.category', model.l.get "nteeMajor.#{row.nteeMajor}"
                z '.text', row.purpose
          }
          {
            key: 'location', name: model.l.get('general.location'), width: 150
            content: ({row}) ->
              FormatService.location {
                city: row.toCity
                state: row.toState
              }
          }
          {key: 'year', name: model.l.get('general.year'), width: 100}
        ]

$fundGrantName = ({model, router, row}) ->
  hasEin = model.irsOrg.isEin row.toId
  nameTag = if hasEin then 'a' else 'div'
  nameFn = if hasEin then router.link else ((n) -> n)
  nameFn z "#{nameTag}.name", {
    href: router.get 'orgByEin', {ein: row.toId}
  }, row.toName

$fundGrantsMobileRow = ({model, router, row}) ->
  z '.z-fund-grants-mobile-row',
    z '.name',
      z $fundGrantName, {model, router, row}
    z '.location',
      FormatService.location {
        city: row.toCity
        state: row.toState
      }
    z '.divider'
    z '.purpose',
      z '.category', model.l.get "nteeMajor.#{row.nteeMajor}"
      z '.text', row.purpose
    z '.stats',
      z '.stat',
        z '.title', model.l.get 'general.year'
        z '.value', row.year
      z '.stat',
        z '.title', model.l.get 'general.amount'
        z '.value',
          FormatService.abbreviateDollar row.amount
