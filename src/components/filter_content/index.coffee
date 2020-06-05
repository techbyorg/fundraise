import {z, classKebab, useContext, useMemo, useStream} from 'zorium'
import * as _ from 'lodash-es'
import * as Rx from 'rxjs'
import * as rx from 'rxjs/operators'

import $filterContentBooleanList from '../filter_content_boolean_list'
import $filterContentList from '../filter_content_list'
# import $filterContentGtlt from '../filter_content_gtlt'
import $filterContentMinMax from '../filter_content_min_max'

if window?
  require './index.styl'

export default $filterContent = (props) ->
  {filter, valueStreams, filterValue, isGrouped,
    overlayAnchor, $$parentRef} = props

  filterValueStr = JSON.stringify filterValue # for "deep" compare

  z '.z-filter-content', {
    # we want all inputs, etc... to restart w/ new valueStreams
    key: "#{filterValueStr}"
  },
    switch filter.type
      when 'listBooleanAnd', 'listBooleanOr', 'fieldList', 'booleanArraySubTypes'
        z $filterContentBooleanList, {
          filterValueStr, filter, valueStreams, filterValue
        }
      when 'listAnd', 'listOr', 'fieldList'
        z $filterContentList, {
          filterValueStr, filter, valueStreams, filterValue
        }
      when 'minMax'
        z $filterContentMinMax, {
          filterValueStr, filter, valueStreams, filterValue,
          overlayAnchor, $$parentRef
        }
      # when 'gtlt'
      #   z $filterContentGtlt, {filterValueStr, valueStream, filterValue}
