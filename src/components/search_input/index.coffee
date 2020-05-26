{z, useRef, useLayoutEffect} = require 'zorium'

if window?
  require './index.styl'

module.exports = $searchInput = ({placeholder, valueStream}) ->
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
