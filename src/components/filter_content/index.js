/* eslint-disable
    no-duplicate-case,
    no-unused-vars,
*/
// TODO: This file was created by bulk-decaffeinate.
// Fix any style issues and re-enable lint.
import { z, classKebab, useContext, useMemo, useStream } from 'zorium'
import * as _ from 'lodash-es'
import * as Rx from 'rxjs'
import * as rx from 'rxjs/operators'

import $filterContentBooleanList from '../filter_content_boolean_list'
import $filterContentList from '../filter_content_list'
import $filterContentNtee from '../filter_content_ntee'
// import $filterContentGtlt from '../filter_content_gtlt'
import $filterContentMinMax from '../filter_content_min_max'
let $filterContent

if (typeof window !== 'undefined' && window !== null) {
  require('./index.styl')
}

export default $filterContent = function (props) {
  let $$parentRef, filter, filterValue, isGrouped, overlayAnchor, resetValue, valueStreams;
  ({
    filter, valueStreams, filterValue, resetValue, isGrouped, resetValue,
    overlayAnchor, $$parentRef
  } = props)

  let filterValueStr = filterValue && JSON.stringify(filterValue) // "deep" compare
  if (!filterValueStr) { filterValueStr = '' }

  return z('.z-filter-content',
    (() => {
      switch (filter.type) {
        case 'listBooleanAnd': case 'listBooleanOr': case 'fieldList': case 'booleanArraySubTypes':
          return z($filterContentBooleanList, {
            filterValueStr, resetValue, filter, valueStreams, filterValue
          })
        case 'listAnd': case 'listOr': case 'fieldList':
          return z($filterContentList, {
            filterValueStr, resetValue, filter, valueStreams, filterValue
          })
        case 'ntee':
          return z($filterContentNtee, {
            filterValueStr, resetValue, filter, valueStreams, filterValue
          })
        case 'minMax':
          return z($filterContentMinMax, {
            filterValueStr,
            resetValue,
            filter,
            valueStreams,
            filterValue,
            overlayAnchor,
            $$parentRef
          })
      }
    })())
}
// when 'gtlt'
// z $filterContentGtlt, {
//   filterValueStr, resetValue, valueStream, filterValue
// }
