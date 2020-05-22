{z, classKebab, useRef, useMemo, useStream} = require 'zorium'
RxBehaviorSubject = require('rxjs/BehaviorSubject').BehaviorSubject
RxObservable = require('rxjs/Observable').Observable
require 'rxjs/add/observable/of'

colors = require '../../colors'

if window?
  require './index.styl'

$buttonMenu = require '../button_menu'
$icon = require '../icon'

module.exports = SearchInput = (props) ->
  {model, searchValueStream, searchValueStreams, router,
    isFocusedStream, onFocus, $topLeftButton, $topRightButton, placeholder, onBack,
    height, bgColor, clearOnBack, isAppBar, alwaysShowBack
    isSearchOnSubmit, onclick, onsubmit, onfocus, onblur, ontouchstart} = props

  $$ref = useRef()

  {isFocusedStream} = useMemo ->
    {
      isFocusedStream: isFocusedStream or new RxBehaviorSubject false
    }
  , []

  {isFocused, searchValue} = useStream ->
    isFocused: isFocusedStream
    searchValue: searchValueStreams?.switch() or searchValueStream

  open = ->
    onFocus?()
    isFocused.next true

  close = ->
    isFocused.next false

  clear = ->
    if searchValueStreams
      searchValueStreams.next RxObservable.of ''
    else
      searchValueStream.next ''

  onBack ?= ->
    router.back()
  clearOnBack ?= true
  height ?= '48px'
  bgColor ?= colors.$bgColor
  placeholder ?= model.l.get 'searchInput.placeholder'

  # TODO: json file with vars that are used in stylus and js
  # eg $breakPointLarge
  isButtonMenuVisible = not window?.matchMedia('(min-width: 1280px)').matches

  z '.z-search-input', {
    ref: $el
    className: classKebab {
      isFocused, isSearchOnSubmit, isServerSide: not window?
    }
    onclick: (e) ->
      if onclick
        e?.preventDefault()
        onclick?()
  },
    z '.search-overlay', {
      style:
        height: height
    },
      unless isSearchOnSubmit
        z '.left-icon',
          if isAppBar and isButtonMenuVisible and not alwaysShowBack
            z $buttonMenu, {
              model, router, isAlignedLeft: false
            }
          else
            z $icon,
              icon: if isFocused or alwaysShowBack then 'back' else 'search'
              color: if isFocused or alwaysShowBack \
                     then colors.$bgText70 \
                     else colors.$bgText26
              onclick: (e) ->
                onBack? e
                if clearOnBack
                  clear()
                close()
                $$ref?.querySelector('.input').blur()
      z '.right-icon',
        if $icon
          $topRightButton
        else if (searchValue or isSearchOnSubmit) and not isAppBar
          z $icon,
            icon: 'search'
            color: if isSearchOnSubmit and not searchValue \
                   then colors.$bgText54 \
                   else colors.$bgText
            touchHeight: height
            onclick: ->
              onsubmit?()
    z 'form.form', {
      onsubmit: (e) ->
        e.preventDefault()
        onsubmit?()
        document.activeElement.blur() # hide keyboard
      style:
        height: height
    },
      z 'input.input',
        type: 'text'
        placeholder: placeholder
        value: if window? then searchValue
        onfocus: (e) ->
          open e
          onfocus? e
        onblur: (e) ->
          close e
          onblur? e
        ontouchstart: (e) ->
          ontouchstart? e
        style:
          backgroundColor: bgColor
        oninput: (e) ->
          if searchValueStreams
            searchValueStreams.next RxObservable.of e.target.value
          else
            searchValue.next e.target.value
