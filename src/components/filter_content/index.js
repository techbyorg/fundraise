import {z, classKebab, useContext, useMemo, useStream} from 'zorium'
import * as _ from 'lodash-es'
import * as Rx from 'rxjs'
import * as rx from 'rxjs/operators'

import $filterContentBooleanList from '../filter_content_boolean_list'
import $filterContentList from '../filter_content_list'
import $filterContentNtee from '../filter_content_ntee'
# import $filterContentGtlt from '../filter_content_gtlt'
import $filterContentMinMax from '../filter_content_min_max'

if window?
  require './index.styl'

export default $filterContent = (props) ->
  {filter, valueStreams, filterValue, resetValue, isGrouped, resetValue,
    overlayAnchor, $$parentRef} = props

  filterValueStr = filterValue and JSON.stringify filterValue # "deep" compare
  filterValueStr or= ''

  z '.z-filter-content',
    switch filter.type
      when 'listBooleanAnd', 'listBooleanOr', 'fieldList', 'booleanArraySubTypes'
        z $filterContentBooleanList, {
          filterValueStr, resetValue, filter, valueStreams, filterValue
        }
      when 'listAnd', 'listOr', 'fieldList'
        z $filterContentList, {
          filterValueStr, resetValue, filter, valueStreams, filterValue
        }
      when 'ntee'
        z $filterContentNtee, {
          filterValueStr, resetValue, filter, valueStreams, filterValue
        }
      when 'minMax'
        z $filterContentMinMax, {
          filterValueStr, resetValue, filter, valueStreams, filterValue,
          overlayAnchor, $$parentRef
        }
      # when 'gtlt'
        # z $filterContentGtlt, {
        #   filterValueStr, resetValue, valueStream, filterValue
        # }
