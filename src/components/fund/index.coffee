{z, classKebab, useContext, useMemo, useStream} = require 'zorium'
RxBehaviorSubject = require('rxjs/BehaviorSubject').BehaviorSubject

$fundAtAGlance = require '../fund_at_a_glance'
$fundOverview = require '../fund_overview'
$fundGrants = require '../fund_grants'
$fundPersons = require '../fund_persons'
$fundApplicationInfo = require '../fund_application_info'
$fund990s = require '../fund_990s'
$tapTabs = require '../tap_tabs'
context = require '../../context'

if window?
  require './index.styl'

module.exports = $fund = ({placeholderNameStream, irsFundStream}) ->
  {lang} = useContext context

  {selectedIndexStream} = useMemo ->
    {selectedIndexStream: new RxBehaviorSubject 0}
  , []

  {irsFund, selectedIndex} = useStream ->
    irsFund: irsFundStream
    selectedIndex: selectedIndexStream

  tabs = [
    {
      name: lang.get 'fund.tabOverview'
      $el: $fundOverview
    }
    {
      name: lang.get 'fund.tabGrants'
      $el: $fundGrants
    }
    {
      name: lang.get 'fund.tabPersons'
      $el: $fundPersons
    }
    {
      name: lang.get 'fund.tabApplicationInfo'
      $el: $fundApplicationInfo
    }
    {
      name: lang.get 'fund.tab990s'
      $el: $fund990s
    }
  ]

  z '.z-fund', {
    className: classKebab {scrollFitContent: not (selectedIndex in [1, 2])}
  },
    z '.quick-info',
      z $fundAtAGlance, {placeholderNameStream, irsFund}

    z '.content',
      z '.inner',
        z $tapTabs, {
          selectedIndexStream, tabs, tabProps: {
            irsFund, irsFundStream
          }
        }
