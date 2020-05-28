import {z, useRef, useLayoutEffect} from 'zorium'

if window?
  require './index.styl'

export default $searchInput = ({placeholder, valueStream}) ->
  # {value} = useStream ->
  #   value: valueStream

  $$ref = useRef()

  useLayoutEffect ->
    $$ref.current.focus()
  , []

  z 'input.z-search-input',
    ref: $$ref
    placeholder: placeholder
    oninput: (e) ->
      valueStream.next e.target.value
