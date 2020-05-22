{z, classKebab, useMemo, useStream} = require 'zorium'
_map = require 'lodash/map'
_uniq = require 'lodash/uniq'
RxBehaviorSubject = require('rxjs/BehaviorSubject').BehaviorSubject

Icon = require '../icon'
Button = require '../button'
Privacy = require '../privacy'
Tos = require '../tos'
Environment = require '../../services/environment'
colors = require '../../colors'
config = require '../../config'

if window?
  require './index.styl'

module.exports = $policies = ({model, router, isIabStream, $dropdowns}) ->
  $dropdowns = [
    {
      $title: 'Privacy Policy'
      $content: z $privacy, {model, router}
      isVisible: false
    }
    {
      $title: 'Terms of Service'
      $content: z $tos, {model, router}
      isVisible: false
    }
  ]

  {visibleDropdownsStream} = useMemo ->
    {
      visibleDropdownsStream: new RxBehaviorSubject []
    }
  , []

  {isIab, visibleDropdowns} = useStream ->
    isIab: isIab
    visibleDropdowns: visibleDropdownsStream

  z '.z-policies',
    z '.title', model.l.get 'policies.title'
    z '.description',
      model.l.get 'policies.description'

    _map $dropdowns, ($dropdown, i) ->
      {$content, $title} = $dropdown
      isVisible = visibleDropdowns.indexOf(i) isnt -1
      [
        z '.divider'
        z '.dropdown',
          z '.block', {
            onclick: ->
              if isVisible
                visibleDropdownsStream.next _filter visibleDropdowns, (index) ->
                  index isnt i
              else
                visibleDropdownsStream.next _uniq visibleDropdowns.concat i
          },
            z '.title', $title
            z '.icon',
              z $icon,
                icon: 'expand-more'
                isTouchTarget: false
                color: colors.$primaryMain
          z '.content', {className: classKebab {isVisible}},
            $content
      ]

    unless isIab
      z '.continue-button',
        z $button,
          text: 'Continue'
          onclick: ->
            router.goPath '/'
