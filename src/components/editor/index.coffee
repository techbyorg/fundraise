{z, classKebab, useMemo, useStream, useCallback, useEffect} = require 'zorium'
{Editor, Transforms, createEditor} = require 'slate'
{Slate, Editable, withReact} = require 'slate-react'
{isHotkey} = require 'is-hotkey'
_map = require 'lodash/map'
RxBehaviorSubject = require('rxjs/BehaviorSubject').BehaviorSubject
RxReplaySubject = require('rxjs/ReplaySubject').ReplaySubject
RxObservable = require('rxjs/Observable').Observable
require 'rxjs/add/observable/of'

$icon = require '../icon'
$uploadOverlay = require '../upload_overlay'
# $uploadImagePreview = require '../upload_image_preview'
config = require '../../config'
colors = require '../../colors'

if window?
  require './index.styl'

HOTKEYS = {
  'mod+b': 'bold',
  'mod+i': 'italic',
  'mod+u': 'underline',
  'mod+`': 'code',
}
MODIFIERS = [
  {icon: 'bold', title: 'Bold', mark: 'bold', key: 'mod+b'}
  {icon: 'italic', title: 'Italic', mark: 'italic', key: 'mod+i'}
  {icon: 'underline', title: 'Underline', mark: 'underline', key: 'mod+u'}
  {icon: 'code', title: 'Code', mark: 'code', key: 'mod+`'}
  {icon: 'bullet-list', title: 'List', block: 'bulleted-list'}
  {icon: 'image', title: 'Image'}
]

LIST_TYPES = ['numbered-list', 'bulleted-list']


module.exports = EditorComponent = (props) ->
  {model, valueStreams, uploadFn} = props

  {editor, valueStreams} = useMemo ->
    valueStreams ?= new RxReplaySubject 1
    valueStreams.next RxObservable.of [
      {
        type: 'paragraph',
        children: [{ text: 'A line of text in a paragraph.' }]
      }
    ]

    {
      editor: withReact createEditor()
      valueStreams: valueStreams
    }
  , []

  {value} = useStream ->
    value: valueStreams.switch()

  # FIXME: shouldn't need this
  value ?= [
    {
      type: 'paragraph',
      children: [{ text: 'loading' }]
    }
  ]

  renderElement = useCallback (props) ->
    Element props
  , []

  renderLeaf = useCallback (props) ->
    console.log 'render leaf', props
    Leaf props
  , []


  z '.z-editor',
    z '.textarea',
      # FIXME: should work server-side?
      if window?
        z Slate, {
          editor
          value
          onChange: (val) ->
            console.log val
            valueStreams.next RxObservable.of val
        },
          z Editable, {
            # style:
            #   height: '100px'
            #   background: '#eee'
            renderElement: renderElement
            renderLeaf: renderLeaf
            # placeholder: 'Placeholder...'
            spellCheck: true
            autoFocus: true
            onKeyDown: (e) ->
              console.log 'keydown'
              _map HOTKEYS, (mark, hotkey) ->
                if isHotkey hotkey, e
                  console.log 'ishotkey', hotkey
                  e.preventDefault()
                  mark = HOTKEYS[hotkey]
                  toggleMark editor, mark
          }

    z '.panel',
      _map MODIFIERS, (options) ->
        {icon, title, mark, block, isImage, onclick} = options

        if isImage and not imagesAllowed
          return

        isActive = if block \
                   then isBlockActive editor, block \
                   else isMarkActive editor, mark

        z '.icon', {
          title: title
          className: classKebab {isActive}
        },
          z $icon, {
            icon: icon
            color: colors.$bgText
            onmousedown: (e) ->
              console.log 'click', mark
              if onclick
                onclick()
              else
                e.preventDefault()
                console.log 'toggle'
                if mark
                  toggleMark editor, mark
                else if block
                  toggleBlock editor, block
          }
          if isImage
            z '.upload-overlay',
              z $uploadOverlay, {
                onSelect: ({file, dataUrl}) ->
                  img = new Image()
                  img.src = dataUrl
                  img.onload = ->
                    imageData.next {
                      file
                      dataUrl
                      width: img.width
                      height: img.height
                    }
                    # model.overlay.open z $uploadImagePreview, {
                    #   imageData
                    #   model
                    #   uploadFn
                    #   onUpload: ({prefix, aspectRatio}) ->
                    #     # attachments or= []
                    #     # attachmentsValueStreams.next RxObservable.of(attachments.concat [
                    #     #   {type: 'image', prefix}
                    #     # ])
                    #
                    #     src = model.image.getSrcByPrefix prefix, {size: 'large'}
                    #
                    #     $textarea.setModifier {
                    #       pattern: "![](<#{src} =#{aspectRatio}>)"
                    #     }
                    # }
              }

Element = ({ attributes, children, element }) ->
  switch element.type
    when 'block-quote' then z 'blockquote', attributes, children
    when 'bulleted-list' then z 'ul', attributes, children
    when 'heading-one' then z 'h1', attributes, children
    when 'heading-two' then z 'h2', attributes, children
    when 'list-item' then z 'li', attributes, children
    when 'numbered-list' then z 'ol', attributes, children
    else z 'p', attributes, children

Leaf = ({ attributes, children, leaf }) ->
  if leaf.bold
    children = z 'strong', children

  if leaf.code
    children = z 'code', children

  if leaf.italic
    children = z 'em', children

  if leaf.underline
    children = z 'u', children

  return z 'span', attributes, children

isMarkActive = (editor, format) ->
  marks = Editor.marks(editor)
  return if marks then marks[format] is true else false

toggleMark = (editor, format) ->
  isActive = isMarkActive editor, format

  if isActive
    Editor.removeMark editor, format
  else
    Editor.addMark editor, format, true


isBlockActive = (editor, format) ->
  [match] = Editor.nodes editor, {
    match: (n) => n.type is format
  }

  return Boolean match

toggleBlock = (editor, format) ->
  isActive = isBlockActive editor, format
  isList = LIST_TYPES.includes format

  Transforms.unwrapNodes editor, {
    match: (n) -> LIST_TYPES.includes(n.type)
    split: true
  }

  Transforms.setNodes editor, {
    type: if isActive then 'paragraph' else if isList then 'list-item' else format
  }

  if not isActive and isList
    block = { type: format, children: [] }
    Transforms.wrapNodes editor, block
