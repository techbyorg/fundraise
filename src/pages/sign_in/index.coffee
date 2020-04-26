{z, useCallback, useEffect, useMemo, useStream} = require 'zorium'
RxBehaviorSubject = require('rxjs/BehaviorSubject').BehaviorSubject
{isHotkey} = require 'is-hotkey'
console.log isHotkey
_map = require 'lodash/map'

$appBar = require '../../components/app_bar'
$signIn = require '../../components/sign_in'
config = require '../../config'

{ Editor, Transforms, createEditor } = require 'slate'

{ Slate, Editable, withReact } = require 'slate-react'

if window?
  require './index.styl'

HOTKEYS = {
  'mod+b': 'bold',
  'mod+i': 'italic',
  'mod+u': 'underline',
  'mod+`': 'code',
}
LIST_TYPES = ['numbered-list', 'bulleted-list']


module.exports = SignInPage = ({model, router, entityStream}) ->
  unless window?
    return z '.p-sign-in'

  editor = useMemo ->
    withReact createEditor()
  , []

  {meStream, valueStream} = useMemo ->
    {
      meStream: model.user.getMe()
      valueStream: new RxBehaviorSubject [
        {
          type: 'paragraph',
          children: [{ text: 'A line of text in a paragraph.' }]
        }
      ]
    }
  , []

  {me, user, entities, value} = useStream ->
    me: meStream
    user: meStream.switchMap (me) ->
      model.user.getById me.data.me.id
    entities: meStream.switchMap (me) ->
      model.entity.getAllByUserId me.data.me.id
    value: valueStream

  renderElement = useCallback (props) ->
    Element props
  , []
  renderLeaf = useCallback (props) ->
    console.log 'render leaf', props
    Leaf props
  , []

  console.log 'MEEEEEEe', me
  console.log 'USERRRR', user
  console.log 'entities', entities

  z '.p-sign-in',
    z $appBar, {
      model
      hasLogo: true
      # $topLeftButton: z $buttonBack, {color: colors.$header500Icon}
    }
    z Slate, {
      editor
      value
      onChange: (val) ->
        console.log val
        valueStream.next val
    },
      z 'button', {
        active: isBlockActive editor, 'numbered-list'
        onMouseDown: (e) ->
          e.preventDefault()
          toggleBlock editor, 'numbered-list'
      },
        'numbered-list'
      z Editable, {
        renderElement: renderElement
        style:
          height: '100px'
          background: '#eee'
        renderLeaf: renderLeaf
        placeholder: 'Placeholder...'
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
    # z $signIn, {model, router, entityStream}

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
