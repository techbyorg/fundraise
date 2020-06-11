import {z, useContext, useMemo, useStream} from 'zorium'
import * as rx from 'rxjs/operators'

import $table from 'frontend-shared/components/table'
import FormatService from 'frontend-shared/services/format'

import context from '../../context'

if window?
  require './index.styl'

export default $fundGrants = ({irsFund, irsFundStream}) ->
  {model, browser, lang} = useContext context

  {contributionsStream} = useMemo ->
    {
      contributionsStream: irsFundStream.pipe rx.switchMap (irsFund) ->
        model.irsContribution.getAllByFromEin irsFund.ein, {limit: 100}
    }
  , []

  {contributions, breakpoint} = useStream ->
    contributions: contributionsStream
    breakpoint: browser.getBreakpoint()

  z '.z-fund-grants',
    z '.grants',
      z $table,
        breakpoint: breakpoint
        data: contributions?.nodes
        mobileRowRenderer: $fundGrantsMobileRow
        columns: [
          {
            key: 'amount', name: lang.get('general.amount'), width: 150
            content: ({row}) ->
              "$#{FormatService.number row.amount}"
          }
          {
            key: 'toId', name: 'Name', width: 300
            content: $fundGrantName
          }
          {
            key: 'purpose', name: lang.get('fundGrants.purpose'), width: 300, isFlex: true
            content: ({row}) ->
              z '.purpose',
                z '.category', lang.get "nteeMajor.#{row.nteeMajor}"
                z '.text', row.purpose
          }
          {
            key: 'location', name: lang.get('general.location'), width: 150
            content: ({row}) ->
              FormatService.location {
                city: row.toCity
                state: row.toState
              }
          }
          {key: 'year', name: lang.get('general.year'), width: 100}
        ]

$fundGrantName = ({row}) ->
  {model, router} = useContext context
  hasEin = model.irsOrg.isEin row.toId
  hasEin = false # FIXME: add org page
  nameTag = if hasEin then 'a' else 'div'
  nameFn = if hasEin then router.link else ((n) -> n)
  nameFn z "#{nameTag}.name", {
    href: if hasEin then router.get 'orgByEin', {
      ein: row.toId
      slug: _.kebabCase row.toName
    }
  }, row.toName

$fundGrantsMobileRow = ({row}) ->
  {lang} = useContext context
  z '.z-fund-grants-mobile-row',
    z '.name',
      z $fundGrantName, {row}
    z '.location',
      FormatService.location {
        city: row.toCity
        state: row.toState
      }
    z '.divider'
    z '.purpose',
      z '.category', lang.get "nteeMajor.#{row.nteeMajor}"
      z '.text', row.purpose
    z '.stats',
      z '.stat',
        z '.title', lang.get 'general.year'
        z '.value', row.year
      z '.stat',
        z '.title', lang.get 'general.amount'
        z '.value',
          FormatService.abbreviateDollar row.amount
