{z, useMemo, useStream} = require 'zorium'
_map = require 'lodash/map'
RxBehaviorSubject = require('rxjs/BehaviorSubject').BehaviorSubject
RxObservable = require('rxjs/Observable').Observable
require 'rxjs/add/observable/of'

$icon = require '../icon'
$uploadOverlay = require '../upload_overlay'
$uploadImagePreview = require '../upload_image_preview'
$textarea = require '../textarea'
config = require '../../config'
colors = require '../../colors'

if window?
  require './index.styl'

module.exports = MarkdownEditor = (props) ->
  {model, valueStreams, attachmentsValueStreams, valueStream,
    errorStream, uploadFn, hintText, imagesAllowed = true} = props

  {valueStream, errorStream, imageDataStream} = useMemo ->
    {
      valueStream: valueStream or new RxBehaviorSubject ''
      errorStream: errorStream or new RxBehaviorSubject null
      imageDataStream: imageDataStream or new RxBehaviorSubject null
    }
  , []


  modifiers = [
    {
      icon: 'bold'
      title: 'Bold'
      pattern: '**$0**'
    }
    {
      icon: 'italic'
      title: 'Italic'
      pattern: '*$0*'
    }
    # markdown doesn't support...
    # {
    #   icon: 'underline'
    #   title: 'Underline'
    #   pattern: '__$0__'
    # }
    {
      icon: 'bullet-list'
      title: 'List'
      pattern: '- $0'
    }
    {
      icon: 'image'
      title: 'Image'
      pattern: '![]($1)'
      isImage: true
    }
  ]

  {attachments} = useStream ->
    attachments: attachmentsValueStreams?.switch()

  z '.z-markdown-editor',
    z '.textarea',
      z $textarea, {
        valueStreams, errorStream, hintText, isFull: true
      }

    z '.panel',
      _map modifiers, (options) ->
        {icon, title, pattern, isImage, onclick} = options

        if isImage and not imagesAllowed
          return

        z '.icon', {
          title: title
        },
          z $icon, {
            icon: icon
            color: colors.$bgText
            onclick: ->
              if onclick
                onclick()
              else
                $textarea.setModifier {pattern, onclick}
          }
          if $uploadOverlay
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
                    model.overlay.open z $uploadImagePreview, {
                      imageData
                      model
                      uploadFn
                      onUpload: ({prefix, aspectRatio}) ->
                        attachments or= []
                        attachmentsValueStreams.next RxObservable.of(attachments.concat [
                          {type: 'image', prefix}
                        ])

                        src = model.image.getSrcByPrefix prefix, {size: 'large'}

                        $textarea.setModifier {
                          pattern: "![](<#{src} =#{aspectRatio}>)"
                        }
                    }
              }
