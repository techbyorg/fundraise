{z, classKebab, useMemo, useStream} = require 'zorium'
RxBehaviorSubject = require('rxjs/BehaviorSubject').BehaviorSubject

$fundAtAGlance = require '../fund_at_a_glance'
$fundOverview = require '../fund_overview'
$fundGrants = require '../fund_grants'
$fundPersons = require '../fund_persons'
$fundApplicationInfo = require '../fund_application_info'
$fund990s = require '../fund_990s'
$tapTabs = require '../tap_tabs'

if window?
  require './index.styl'

module.exports = $fund = (props) ->
  {model, router, placeholderNameStream, irsFundStream} = props

  {selectedIndexStream} = useMemo ->
    {selectedIndexStream: new RxBehaviorSubject 0}
  , []

  {irsFund, selectedIndex} = useStream ->
    irsFund: irsFundStream
    selectedIndex: selectedIndexStream

  tabs = [
    {
      name: model.l.get 'fund.tabOverview'
      $el: $fundOverview
    }
    {
      name: model.l.get 'fund.tabGrants'
      $el: $fundGrants
    }
    {
      name: model.l.get 'fund.tabPersons'
      $el: $fundPersons
    }
    {
      name: model.l.get 'fund.tabApplicationInfo'
      $el: $fundApplicationInfo
    }
    {
      name: model.l.get 'fund.tab990s'
      $el: $fund990s
    }
  ]

  z '.z-fund', {
    className: classKebab {scrollFitContent: not (selectedIndex in [1, 2])}
  },
    z '.quick-info',
      z $fundAtAGlance, {model, router, placeholderNameStream, irsFund}

    z '.content',
      z '.inner',
        z $tapTabs, {
          selectedIndexStream, tabs, tabProps: {
            model, router, irsFund, irsFundStream
          }
        }
