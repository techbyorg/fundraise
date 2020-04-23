{z, classKebab, useMemo, useStream} = require 'zorium'
_map = require 'lodash/map'
_filter = require 'lodash/filter'
_take = require 'lodash/take'
_isEmpty = require 'lodash/isEmpty'
_orderBy = require 'lodash/orderBy'
_clone = require 'lodash/clone'
_find = require 'lodash/find'
_some = require 'lodash/some'
RxBehaviorSubject = require('rxjs/BehaviorSubject').BehaviorSubject
RxObservable = require('rxjs/Observable').Observable
require 'rxjs/add/observable/combineLatest'
require 'rxjs/add/operator/map'
require 'rxjs/add/operator/startWith'

$icon = require '../icon'
$button = require '../button'
$drawer = require '../drawer'
$ripple = require '../ripple'
Environment = require '../../services/environment'
colors = require '../../colors'
config = require '../../config'

if window?
  IScroll = require 'iscroll/build/iscroll-lite-snap-zoom.js'
  require './index.styl'

module.exports = NavDrawer = ({model, router, entityStream, currentPath}) ->

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
        model.l.getLanguage().startWith(null)
        isRateLoadingStream.startWith(null)
      )
      entityAndMyEntities: RxObservable.combineLatest(
        entityStream
        myEntitiesStream
        meStream
        model.l.getLanguage()
        (vals...) -> vals
      )
    }
  , []

  {isOpen, language, me, expandedItems, entity, windowSize, drawerWidth,
    breakpoint, menuItems} = useStream ->
    isOpen: model.drawer.isOpen()
    language: model.l.getLanguage()
    me: meStream
    expandedItems: expandedItemsStream
    entity: entityStream
    # myEntities: entityAndMyEntities.map (props) ->
    #   [entity, entities, me, language] = props
    #   entities = _orderBy entities, (entity) ->
    #     model.cookie.get("entity_#{entity.id}_lastVisit") or 0
    #   , 'desc'
    #   entities = _filter entities, ({id}) ->
    #     id isnt entity.id
    #   myEntities = _map entities, (entity, i) ->
    #     {
    #       entity
    #       slug: entity.slug
    #     }
    #   myEntities

    windowSize: model.window.getSize()
    drawerWidth: model.window.getDrawerWidth()
    breakpoint: model.window.getBreakpoint()

    menuItems: menuItemsInfoStream.map (menuItemsInfo) ->
      [me, entity, language, isRateLoading] = menuItemsInfo

      meEntityUser = entity?.meEntityUser

      userAgent = model.window.getUserAgent()
      isNativeApp = Environment.isNativeApp({userAgent})
      needsApp = userAgent and
                not isNativeApp and
                not window?.matchMedia('(display-mode: standalone)').matches

      isMember = Boolean me?.email
      hasStripeId = me?.flags?.hasStripeId

      _filter([
        {
          path: router.get 'donate'
          title: model.l.get 'general.organizations'
          iconName: 'briefcase'
          isDefault: true
        }
        {
          path: router.get 'notifications'
          title: model.l.get 'general.notifications'
          iconName: 'notifications'
        }
        # if needsApp or isNativeApp
        #   {
        #     isDivider: true
        #   }
        # if needsApp
        #   {
        #     onclick: ->
        #       model.portal.call 'app.install', {entity}
        #       model.drawer.close()
        #     title: model.l.get 'drawer.menuItemNeedsApp'
        #     iconName: 'get'
        #   }
        # else if isNativeApp
        #   {
        #     onclick: ->
        #       ga? 'send', 'event', 'drawer', 'rate'
        #       isRateLoading.next true
        #       # once ios app v2.0.0+ is out, use this
        #       # model.portal.call 'app.rate'
        #       model.portal.appRate()
        #       .catch (err) ->
        #         isRateLoading.next false
        #       .then ->
        #         isRateLoading.next false
        #         model.drawer.close()
        #     title: if isRateLoading \
        #            then model.l.get 'general.loading' \
        #            else model.l.get 'drawer.menuItemRate'
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
      expandedItems = _clone expandedItems
      expandedItems.splice expandedItems.indexOf(path), 1
      expandedItemsStream.next expandedItems
    else
      expandedItemsStream.next expandedItems.concat [path]



  entity ?= {}

  console.log 'entity', entity

  translateX = if isOpen then 0 else "-#{drawerWidth}px"
  # adblock plus blocks has-ad
  hasA = false #model.ad.isVisible({isWebOnly: true}) and
    # windowSize?.height > 880 and
    # not Environment.isMobile()

  renderChild = (child, depth = 0) ->
    {path, title, $chevronIcon, children, expandOnClick} = child
    isSelected = currentPath?.indexOf(path) is 0
    isExpanded = isSelected or isExpandedByPath(path or title)

    hasChildren = not _isEmpty children
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
          _map children, (child) ->
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
                #           text: model.l.get 'general.signIn'
                #           onclick: ->
                #             model.overlay.open z $signInOverlay, {model, router, data: 'signIn'}
                #       z '.button',
                #         z $button,
                #           isPrimary: true
                #           isFullWidth: true
                #           text: model.l.get 'general.signUp'
                #           onclick: ->
                #             model.overlay.open z $signInOverlay, {model, router, data: 'join'}
                #     z 'li.divider'
                #   ]
                _map menuItems, (menuItem) ->
                  {path, onclick, title, $chevronIcon, isNew,
                    iconName, isDivider, children, expandOnClick
                    color} = menuItem

                  hasChildren = not _isEmpty children

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
                        _map children, (child) ->
                          renderChild child, 1

                # unless _isEmpty myEntities
                #   z 'li.divider'

            ]
