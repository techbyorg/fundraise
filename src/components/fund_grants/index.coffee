{z, useMemo, useStream} = require 'zorium'
_map = require 'lodash/map'

$table = require '../table'
FormatService = require '../../services/format'

if window?
  require './index.styl'

module.exports = FundGrants = ({model, router, irsFund, irsFundStream}) ->
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
        data: contributions?.nodes
        columns: [
          {
            key: 'amount', name: 'Amount', width: 150
            content: ({row}) ->
              "$#{FormatService.number row.amount}"
          }
          {
            key: 'toId', name: 'Name', width: 300
            content: ({row}) ->
              hasEin = model.irsOrg.isEin row.toId
              nameTag = if hasEin then 'a' else 'div'
              nameFn = if hasEin then router.link else ((n) -> n)
              nameFn z "#{nameTag}.name", {
                href: router.get 'orgByEin', {ein: row.toId}
              }, row.toName
          }
          {
            key: 'purpose', name: 'Purpose', width: 300, isFlex: true
            content: ({row}) ->
              z '.purpose',
                z '.category', model.l.get "nteeMajor.#{row.nteeMajor}"
                z '.text', row.purpose
          }
          {
            key: 'location', name: 'Location', width: 150
            content: ({row}) ->
              FormatService.location {
                city: row.toCity
                state: row.toState
              }
          }
          {key: 'year', name: 'Year', width: 100}
        ]
