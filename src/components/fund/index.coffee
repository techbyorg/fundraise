{z, useStream} = require 'zorium'

$fundAtAGlance = require '../fund_at_a_glance'
$fundOverview = require '../fund_overview'
$fundGrants = require '../fund_grants'
$tapTabs = require '../tap_tabs'

if window?
  require './index.styl'

module.exports = Fund = ({model, router, irsFundStream}) ->
  {irsFund} = useStream ->
    irsFund: irsFundStream

  tabs = [
    {
      name: model.l.get 'fund.tabOverview'
      $el: $fundOverview
    }
    {
      name: model.l.get 'fund.tabGrants'
      $el: $fundGrants
    }
  ]

  z '.z-fund',
    z '.quick-info',
      z $fundAtAGlance, {model, router, irsFund}

    z '.content',
      z '.inner',
        z $tapTabs, {tabs, tabProps: {model, router, irsFund, irsFundStream}}
