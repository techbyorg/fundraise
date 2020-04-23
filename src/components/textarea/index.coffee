{z, classKebab, useRef, useMemo, useStream} = require 'zorium'
_defaults = require 'lodash/defaults'
RxBehaviorSubject = require('rxjs/BehaviorSubject').BehaviorSubject
RxObservable = require('rxjs/Observable').Observable
require 'rxjs/add/observable/of'

allColors = require '../../colors'

if window?
  require './index.styl'

DEFAULT_TEXTAREA_HEIGHT = 59

module.exports = Textarea = (props) ->
  {valueStream, valueStreams, errorStream, isFocusedStream, defaultHeight,
    colors, hintText = '', type = 'text', isFloating, isDisabled, isFull,
    isDark, isCentered} = props

  $$el = useRef()

  {valueStream, errorStream, isFocusedStream, textareaHeightStream} = useMemo ->
    {
      valueStream: valueStream or new RxBehaviorSubject ''
      errorStream: errorStream or new RxBehaviorSubject null
      isFocusedStream: isFocusedStream or new RxBehaviorSubject false
      textareaHeightStream: new RxBehaviorSubject(
        defaultHeight or DEFAULT_TEXTAREA_HEIGHT
      )
    }

  {isFocused, textareaHeight, value, error} = useStream ->
    isFocused: isFocusedStream
    textareaHeight: textareaHeightStream
    value: valueStreams?.switch() or valueStream
    error: errorStream

  useEffect ->
    $$textarea = $$el.querySelector('#textarea')
    valueStreams.take(1).subscribe ->
      setTimeout ->
        resizeTextarea {target: $$textarea}
      , 0
    return null
  , []

  setValueFromEvent = (e) ->
    e?.preventDefault()

    setValue e.target.value

  setValue = (value, {updateDom} = {}) ->
    if valueStreams
      valueStreams.next RxObservable.of value
    else
      value.next value

    if updateDom
      $$textarea.value = value

  setModifier = ({pattern}) ->
    startPos = $$textarea.selectionStart
    endPos = $$textarea.selectionEnd
    selectedText = value.substring startPos, endPos
    newSelectedText = pattern.replace '$0', selectedText
    newOffset = pattern.indexOf '$0'
    if newOffset is -1
      newOffset = pattern.length
    newValue = value.substring(0, startPos) + newSelectedText +
               value.substring(endPos, value.length)
    setValue newValue, {updateDom: true}
    $$textarea.focus()
    $$textarea.setSelectionRange startPos + newOffset, endPos + newOffset

  resizeTextarea = (e) ->
    $$textarea = e.target
    $$textarea.style.height = "#{defaultHeight or DEFAULT_TEXTAREA_HEIGHT}px"
    newHeight = $$textarea.scrollHeight
    $$textarea.style.height = "#{newHeight}px"
    $$textarea.scrollTop = newHeight
    unless textareaHeight is newHeight
      textareaHeight.next newHeight
      onResize?()

  # FIXME: useref for parent to reference this, or just pass in streams?
  getHeightPxStream: ->
    textareaHeightStream.map (height) ->
      Math.min height, 150 # max height in css

  colors = _defaults colors, {
    c500: allColors.$bgText54
    background: allColors.$bgText12
    underline: allColors.$primaryMain
  }

  z '.z-textarea',
    ref: $$el
    className: classKebab {
      isDark
      isFloating
      hasValue: value isnt ''
      isFocused
      isDisabled
      isCentered
      isFull
      isError: error?
    }
    style:
      # backgroundColor: colors.background
      color: colors.c500
      height: "#{textareaHeight}px"
    z '.hint', {
      style:
        color: if isFocused and not error? \
               then colors.c500
    },
      hintText
    z 'textarea.textarea#textarea',
      disabled: if isDisabled then true else undefined
      type: type
      value: value
      oninput: z.ev (e, $$el) ->
        resizeTextarea e
        if valueStreams
          valueStreams.next RxObservable.of $$el.value
        else
          value.next $$el.value
      onfocus: z.ev (e, $$el) ->
        isFocused.next true
      onblur: z.ev (e, $$el) ->
        isFocused.next false

      # onkeyup: setValueFromEvent
      # bug where cursor goes to end w/ just value
      defaultValue: value or ''
    z '.underline-wrapper',
      z '.underline',
        style:
          backgroundColor: if isFocused and not error? \
                           then colors.underline or colors.c500 else null
    if error?
      z '.error', error
