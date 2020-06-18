import { z } from 'zorium'

import $filterContentBooleanList from '../filter_content_boolean_list'
import $filterContentList from '../filter_content_list'
import $filterContentNtee from '../filter_content_ntee'
import $filterContentKeywords from '../filter_content_keywords'
// import $filterContentGtlt from '../filter_content_gtlt'
import $filterContentMinMax from '../filter_content_min_max'

if (typeof window !== 'undefined') { require('./index.styl') }

export default function $filterContent (props) {
  const {
    filter, valueStreams, filterValue, resetValue, overlayAnchor, $$parentRef
  } = props

  let filterValueStr = filterValue && JSON.stringify(filterValue) // "deep" compare
  if (!filterValueStr) { filterValueStr = '' }

  return z('.z-filter-content',
    (() => {
      switch (filter.type) {
        case 'listBooleanAnd': case 'listBooleanOr': case 'fieldList': case 'booleanArraySubTypes':
          return z($filterContentBooleanList, {
            filterValueStr, resetValue, filter, valueStreams, filterValue
          })
        case 'listAnd': case 'listOr':
          return z($filterContentList, {
            filterValueStr, resetValue, filter, valueStreams, filterValue
          })
        case 'ntee': case 'fundedNtee':
          return z($filterContentNtee, {
            filterValueStr, resetValue, filter, valueStreams, filterValue
          })
        case 'keywords': case 'searchPhrase':
          return z($filterContentKeywords, {
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
