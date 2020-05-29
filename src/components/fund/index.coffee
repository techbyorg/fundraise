import {z, classKebab, useContext, useMemo, useStream} from 'zorium'
import * as Rx from 'rxjs'

import $tapTabs from 'frontend-shared/components/tap_tabs'

import $fundAtAGlance from '../fund_at_a_glance'
import $fundOverview from '../fund_overview'
import $fundGrants from '../fund_grants'
import $fundPersons from '../fund_persons'
import $fundApplicationInfo from '../fund_application_info'
import $fund990s from '../fund_990s'
import context from '../../context'

if window?
  require './index.styl'

export default $fund = ({placeholderNameStream, irsFundStream}) ->
  {lang} = useContext context

  {selectedIndexStream} = useMemo ->
    {selectedIndexStream: new Rx.BehaviorSubject 0}
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
