import {z, classKebab, useContext, useMemo, useStream} from 'zorium'
import * as _ from 'lodash-es'
RxBehaviorSubject = require('rxjs/BehaviorSubject').BehaviorSubject
RxObservable = require('rxjs/Observable').Observable
require 'rxjs/add/observable/combineLatest'
require 'rxjs/add/operator/map'
require 'rxjs/add/operator/startWith'

import $button from 'frontend-shared/components/button'
import $drawer from 'frontend-shared/components/drawer'
import $ripple from 'frontend-shared/components/ripple'
import Environment from 'frontend-shared/services/environment'

import $icon from '../icon'
import colors from '../../colors'
import context from '../../context'
import config from '../../config'

if window?
  IScroll = require 'iscroll/build/iscroll-lite-snap-zoom.js'
  require './index.styl'

# TODO: if using this with entity/groupStream, get it from context
export default $navDrawer = ({entityStream, currentPath}) ->
  {model, lang, browser, router} = useContext context

  {meStream, isRateLoadingStream, expandedItemsStream, myEntitiesStream,
    menuItemsInfoStream, entityAndMyEntities} = useMemo ->

    meStream = model.user.getMe()
    myEntitiesStream = meStream.switchMap (me) ->
      RxObservable.of []
    isRateLoadingStream = new RxBehaviorSubject false

    {
      me: meStream
      isRateLoadingStream: isRateLoadingStream
      expandedItemsStream: new RxBehaviorSubject []
      myEntitiesStream: myEntitiesStream
      menuItemsInfoStream: RxObservable.combineLatest(
        meStream.startWith(null)
        entityStream.startWith(null)
        lang.getLanguage().startWith(null)
        isRateLoadingStream.startWith(null)
      )
      entityAndMyEntities: RxObservable.combineLatest(
        entityStream
        myEntitiesStream
        meStream
        lang.getLanguage()
        (vals...) -> vals
      )
    }
  , []

  {isOpen, language, me, expandedItems, entity, windowSize, drawerWidth,
    breakpoint, menuItems} = useStream ->
    isOpen: model.drawer.isOpen()
    language: lang.getLanguage()
    me: meStream
    expandedItems: expandedItemsStream
    entity: entityStream
    # myEntities: entityAndMyEntities.map (props) ->
    #   [entity, entities, me, language] = props
    #   entities = _.orderBy entities, (entity) ->
    #     cookie.get("entity_#{entity.id}_.lastVisit") or 0
    #   , 'desc'
    #   entities = _.filter entities, ({id}) ->
    #     id isnt entity.id
    #   myEntities = _.map entities, (entity, i) ->
    #     {
    #       entity
    #       slug: entity.slug
    #     }
    #   myEntities

    windowSize: browser.getSize()
    drawerWidth: browser.getDrawerWidth()
    breakpoint: browser.getBreakpoint()

    menuItems: menuItemsInfoStream.map (menuItemsInfo) ->
      [me, entity, language, isRateLoading] = menuItemsInfo

      meEntityUser = entity?.meEntityUser

      userAgent = browser.getUserAgent()
      isNativeApp = Environment.isNativeApp({userAgent})
      needsApp = userAgent and
                not isNativeApp and
                not window?.matchMedia('(display-mode: standalone)').matches

      isMember = Boolean me?.email
      hasStripeId = me?.flags?.hasStripeId

      _.filter([
        {
          path: router.get 'donate'
          title: lang.get 'general.organizations'
          iconName: 'briefcase'
          isDefault: true
        }
        {
          path: router.get 'notifications'
          title: lang.get 'general.notifications'
          iconName: 'notifications'
        }
        # if needsApp or isNativeApp
        #   {
        #     isDivider: true
        #   }
        # if needsApp
        #   {
        #     onclick: ->
        #       portal.call 'app.install', {entity}
        #       model.drawer.close()
        #     title: lang.get 'drawer.menuItemNeedsApp'
        #     iconName: 'get'
        #   }
        # else if isNativeApp
        #   {
        #     onclick: ->
        #       ga? 'send', 'event', 'drawer', 'rate'
        #       isRateLoading.next true
        #       # once ios app v2.0.0+ is out, use this
        #       # portal.call 'app.rate'
        #       portal.appRate()
        #       .catch (err) ->
        #         isRateLoading.next false
        #       .then ->
        #         isRateLoading.next false
        #         model.drawer.close()
        #     title: if isRateLoading \
        #            then lang.get 'general.loading' \
        #            else lang.get 'drawer.menuItemRate'
        #     iconName: 'star'
        #   }
        ])

  # useMemo expandedItems
  isExpandedByPath = (path) ->
    expandedItems.indexOf(path) isnt -1

  # useMemo expandedItems
  toggleExpandItemByPath = (path) ->
    isExpanded = isExpandedByPath path

    if isExpanded
      expandedItems = _.clone expandedItems
      expandedItems.splice expandedItems.indexOf(path), 1
      expandedItemsStream.next expandedItems
    else
      expandedItemsStream.next expandedItems.concat [path]



  entity ?= {}

  console.log '----------------------ENTITY', entity

  translateX = if isOpen then 0 else "-#{drawerWidth}px"
  # adblock plus blocks has-ad
  hasA = false #model.ad.isVisible({isWebOnly: true}) and
    # windowSize?.height > 880 and
    # not Environment.isMobile()

  renderChild = (child, depth = 0) ->
    {path, title, $chevronIcon, children, expandOnClick} = child
    isSelected = currentPath?.indexOf(path) is 0
    isExpanded = isSelected or isExpandedByPath(path or title)

    hasChildren = not _.isEmpty children
    z 'li.menu-item',
      z 'a.menu-item-link.is-child', {
        className: classKebab {isSelected}
        href: path
        onclick: (e) ->
          e.preventDefault()
          if expandOnClick
            expand()
          else
            model.drawer.close()
            router.goPath path
      },
        z '.icon'
        title
        if hasChildren
          z '.chevron',
            z $chevronIcon,
              icon: if isExpanded \
                    then 'chevron-up' \
                    else 'chevron-down'
              color: colors.$bgText70
              isAlignedRight: true
              onclick: expand
      if hasChildren and isExpanded
        z "ul.children-#{depth}",
          _.map children, (child) ->
            renderChild child, depth + 1

  z '.z-nav-drawer',
    z $drawer,
      model: model
      isOpenStream: model.drawer.isOpen()
      onOpen: model.drawer.open
      onClose: model.drawer.close
      $content:
        z '.z-nav-drawer_drawer', {
          className: classKebab {hasA}
        },
          z '.header',
            z '.icon'
            z '.name', entity?.name
          z '.content',
            z 'ul.menu',
              [
                # if me and not me?.email
                #   [
                #     z 'li.sign-in-buttons',
                #       z '.button',
                #         z $button,
                #           isPrimary: true
                #           isFullWidth: true
                #           text: lang.get 'general.signIn'
                #           onclick: ->
                #             model.overlay.open z $signInOverlay, {model, router, data: 'signIn'}
                #       z '.button',
                #         z $button,
                #           isPrimary: true
                #           isFullWidth: true
                #           text: lang.get 'general.signUp'
                #           onclick: ->
                #             model.overlay.open z $signInOverlay, {model, router, data: 'join'}
                #     z 'li.divider'
                #   ]
                _.map menuItems, (menuItem) ->
                  {path, onclick, title, $chevronIcon, isNew,
                    iconName, isDivider, children, expandOnClick
                    color} = menuItem

                  hasChildren = not _.isEmpty children

                  if isDivider
                    return z 'li.divider'

                  if menuItem.isDefault
                    isSelected = currentPath is router.get('home') or
                      (currentPath and currentPath.indexOf(path) is 0)
                  else
                    isSelected = currentPath?.indexOf(path) is 0

                  isExpanded = isSelected or isExpandedByPath(path or title)

                  expand = (e) ->
                    e?.stopPropagation()
                    e?.preventDefault()
                    toggleExpandItemByPath path or title

                  z 'li.menu-item', {
                    className: classKebab {isSelected}
                  },
                    z 'a.menu-item-link', {
                      href: path
                      style:
                        if color
                          color: color
                      onclick: (e) ->
                        e.preventDefault()
                        if expandOnClick
                          expand()
                        else if onclick
                          onclick()
                        else if path
                          router.goPath path
                          model.drawer.close()
                    },
                      z '.icon',
                        z $icon,
                          isTouchTarget: false
                          icon: iconName
                          size: '26px'
                          color: if isSelected \
                                 then colors.$primaryMainText \
                                 else color or colors.$primaryMainText54
                      title
                      z '.notification', {
                        className: classKebab {
                          isVisible: menuItem.hasNotification
                        }
                      }
                      if hasChildren
                        z '.chevron',
                          z $chevronIcon,
                            icon: if isExpanded \
                                  then 'chevron-up' \
                                  else 'chevron-down'
                            color: colors.$bgText70
                            isAlignedRight: true
                            touchHeight: '28px'
                            onclick: expand
                      if breakpoint is 'desktop'
                        z $ripple, {color: colors.$bgText54}
                    if hasChildren and isExpanded
                      z 'ul.children',
                        _.map children, (child) ->
                          renderChild child, 1

                # unless _.isEmpty myEntities
                #   z 'li.divider'

            ]
