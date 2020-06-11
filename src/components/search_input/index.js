/* eslint-disable
    no-unused-vars,
*/
// TODO: This file was created by bulk-decaffeinate.
// Fix any style issues and re-enable lint.
import { z, useRef, useLayoutEffect } from 'zorium'
let $searchInput

if (typeof window !== 'undefined' && window !== null) {
  require('./index.styl')
}

export default $searchInput = function ({ placeholder, valueStream }) {
  // {value} = useStream ->
  //   value: valueStream

  const $$ref = useRef()

  useLayoutEffect(() => $$ref.current.focus()
    , [])

  return z('input.z-search-input', {
    ref: $$ref,
    placeholder,
    oninput (e) {
      return valueStream.next(e.target.value)
    }
  }
  )
}
