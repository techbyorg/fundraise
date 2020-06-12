import { z, useRef, useLayoutEffect } from 'zorium'

if (typeof window !== 'undefined') { require('./index.styl') }

export default function $searchInput ({ placeholder, valueStream }) {
  // {value} = useStream ->
  //   value: valueStream

  const $$ref = useRef()

  useLayoutEffect(() => {
    $$ref.current.focus()
  }, [])

  return z('input.z-search-input', {
    ref: $$ref,
    placeholder,
    oninput: (e) => { valueStream.next(e.target.value) }
  })
}
