{z} = require 'zorium'

$fundOverviewLineChart = require '../fund_overview_line_chart'
$fundOverviewNteePie = require '../fund_overview_ntee_pie'
$fundOverviewFundingMap = require '../fund_overview_funding_map'

if window?
  require './index.styl'

module.exports = $fundOverview = ({model, router, irsFund}) ->
  z '.z-fund-overview',
    z '.analytics',
      z '.block',
        z '.head',
          z '.title', model.l.get 'fund.grantsPerYear'
        z $fundOverviewLineChart, {model, irsFund}
    z '.grid',
      z '.block.pie',
        z '.head',
          z '.title', model.l.get 'fundOverview.fundedNtee'
        z $fundOverviewNteePie, {model, irsFund}
      z '.block.map',
        z '.head',
          z '.title', model.l.get 'fundOverview.fundingMap'
        z $fundOverviewFundingMap, {model, irsFund}
