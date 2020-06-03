import {z, useContext} from 'zorium'
import * as _ from 'lodash-es'

import $tags from 'frontend-shared/components/tags'
import FormatService from 'frontend-shared/services/format'

import context from '../../context'
import {nteeColors} from '../../colors'

if window?
  require './index.styl'

VISIBLE_FOCUS_AREAS_COUNT = 2

export default $fundSearchResultsMobileRow = ({row}) ->
  {lang} = useContext context

  focusAreas = _.orderBy row.fundedNteeMajors, 'count', 'desc'
  tags = _.map focusAreas, ({key}) ->
    {
      text: lang.get "nteeMajor.#{key}"
      background: nteeColors[key].bg
      color: nteeColors[key].fg
    }

  z '.z-fund-search-results-mobile-row',
    z '.name', row.name
    z '.location', FormatService.location row
    z '.focus-areas',
      z $tags, {tags, maxVisibleCount: VISIBLE_FOCUS_AREAS_COUNT}
    z '.stats',
      z '.stat',
        z '.title', lang.get 'org.assets'
        z '.value',
          FormatService.abbreviateDollar row.assets
      z '.stat',
        z '.title', lang.get 'fund.medianGrant'
        z '.value',
          FormatService.abbreviateDollar row.lastYearStats?.grantMedian
      z '.stat',
        z '.title', lang.get 'fund.grantsPerYear'
        z '.value',
          FormatService.abbreviateDollar row.lastYearStats?.grantSum
