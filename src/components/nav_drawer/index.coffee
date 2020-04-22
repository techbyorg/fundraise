z = require 'zorium'
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

Icon = require '../icon'
Button = require '../button'
Drawer = require '../drawer'
SignInOverlay = require '../sign_in_overlay'
Environment = require '../../services/environment'
Ripple = require '../ripple'
colors = require '../../colors'
config = require '../../config'

if window?
  IScroll = require 'iscroll/build/iscroll-lite-snap-zoom.js'
  require './index.styl'

module.exports = class NavDrawer
  constructor: ({@model, @router, entity}) ->
    @$socialIcon = new Icon()
    @$signInButton = new Button()
    @$joinButton = new Button()
    @$signInOverlay = new SignInOverlay {@model, @router}
    @$drawer = new Drawer {
      @model
      isOpen: @model.drawer.isOpen()
      onOpen: @model.drawer.open
      onClose: @model.drawer.close
    }

    # don't need to slow down server-side rendering for this
    hasUnreadMessages = if window?
      @model.conversation.getAll().map (conversations) ->
        _some conversations, {isRead: false}
    else
      RxObservable.of null

    me = @model.user.getMe()
    @isRateLoading = new RxBehaviorSubject false
    # settle as soon as one is ready, otherwise the nav menu might flash blank
    # while the others load
    menuItemsInfo = RxObservable.combineLatest(
      me.startWith(null)
      entity.startWith(null)
      @model.l.getLanguage().startWith(null)
      hasUnreadMessages.startWith(null)
      @isRateLoading.startWith(null)
    )

    myEntities = me.switchMap (me) =>
      RxObservable.of []
      # @model.entity.getAllByUserId me.id
    entityAndMyEntities = RxObservable.combineLatest(
      entity
      myEntities
      me
      @model.l.getLanguage()
      (vals...) -> vals
    )

    @state = z.state
      isOpen: @model.drawer.isOpen()
      language: @model.l.getLanguage()
      me: me
      expandedItems: []
      entity: entity
      # myEntities: entityAndMyEntities.map (props) =>
      #   [entity, entities, me, language] = props
      #   entities = _orderBy entities, (entity) =>
      #     @model.cookie.get("entity_#{entity.id}_lastVisit") or 0
      #   , 'desc'
      #   entities = _filter entities, ({id}) ->
      #     id isnt entity.id
      #   myEntities = _map entities, (entity, i) =>
      #     {
      #       entity
      #       slug: entity.slug
      #     }
      #   myEntities

      windowSize: @model.window.getSize()
      drawerWidth: @model.window.getDrawerWidth()
      breakpoint: @model.window.getBreakpoint()

      menuItems: menuItemsInfo.map (menuItemsInfo) =>
        [me, entity, language, hasUnreadMessages, isRateLoading] = menuItemsInfo

        meEntityUser = entity?.meEntityUser

        userAgent = @model.window.getUserAgent()
        isNativeApp = Environment.isNativeApp({userAgent})
        needsApp = userAgent and
                  not isNativeApp and
                  not window?.matchMedia('(display-mode: standalone)').matches

        isMember = Boolean me?.email
        hasStripeId = me?.flags?.hasStripeId

        _filter([
          {
            path: @router.get 'donate'
            title: @model.l.get 'general.organizations'
            $icon: new Icon()
            $ripple: new Ripple()
            iconName: 'briefcase'
            isDefault: true
          }
          {
            path: @router.get 'dashboard'
            title: @model.l.get 'general.notifications'
            $icon: new Icon()
            $ripple: new Ripple()
            iconName: 'notifications'
            hasNotification: hasUnreadMessages
          }
          {
            path: @router.get 'notifications'
            title: @model.l.get 'general.notifications'
            $icon: new Icon()
            $ripple: new Ripple()
            iconName: 'notifications'
            hasNotification: hasUnreadMessages
          }
          # {
          #   path: @router.get 'account'
          #   title: @model.l.get 'general.account'
          #   $icon: new Icon()
          #   $ripple: new Ripple()
          #   iconName: 'account-circle'
          # }
          # {
          #   path: @router.get 'about'
          #   title: @model.l.get 'drawer.about'
          #   $icon: new Icon()
          #   $ripple: new Ripple()
          #   iconName: 'info'
          # }
          # if isMember
          #   {
          #     path: @router.get 'editProfile'
          #     title: @model.l.get 'editProfilePage.title'
          #     $icon: new Icon()
          #     $ripple: new Ripple()
          #     iconName: 'edit'
          #   }
          # {
          #   path: @router.get 'entityPeople', {@router}
          #   title: @model.l.get 'people.title'
          #   $icon: new Icon()
          #   $ripple: new Ripple()
          #   iconName: 'friends'
          # }


          # if @model.entityUser.hasPermission {
          #   meEntityUser, me, permissions: ['manageRole']
          # }
          #   {
          #     # path: @router.get 'adminSettings'
          #     expandOnClick: true
          #     title: @model.l.get 'entitySettingsPage.title'
          #     $icon: new Icon()
          #     $ripple: new Ripple()
          #     iconName: 'settings'
          #     $chevronIcon: new Icon()
          #     children: _filter [
          #       {
          #         path: @router.get 'adminManageChannels'
          #         title: @model.l.get 'adminManageChannelsPage.title'
          #       }
          #       {
          #         path: @router.get 'adminManageRoles'
          #         title: @model.l.get 'adminManageRolesPage.title'
          #       }
          #       if @model.entityUser.hasPermission {
          #         meEntityUser, me, permissions: ['readAuditLog']
          #       }
          #         {
          #           path: @router.get 'adminAuditLog'
          #           title: @model.l.get 'auditLogPage.title'
          #         }
          #       {
          #         path: @router.get 'adminBannedUsers'
          #         title: @model.l.get 'adminBannedUsersPage.title'
          #       }
          #     ]
          #   }
          # if needsApp or isNativeApp
          #   {
          #     isDivider: true
          #   }
          # if needsApp
          #   {
          #     onclick: =>
          #       @model.portal.call 'app.install', {entity}
          #       @model.drawer.close()
          #     title: @model.l.get 'drawer.menuItemNeedsApp'
          #     $icon: new Icon()
          #     $ripple: new Ripple()
          #     iconName: 'get'
          #   }
          # else if isNativeApp
          #   {
          #     onclick: =>
          #       ga? 'send', 'event', 'drawer', 'rate'
          #       @isRateLoading.next true
          #       # once ios app v2.0.0+ is out, use this
          #       # @model.portal.call 'app.rate'
          #       @model.portal.appRate()
          #       .catch (err) =>
          #         @isRateLoading.next false
          #       .then =>
          #         @isRateLoading.next false
          #         @model.drawer.close()
          #     title: if isRateLoading \
          #            then @model.l.get 'general.loading' \
          #            else @model.l.get 'drawer.menuItemRate'
          #     $icon: new Icon()
          #     $ripple: new Ripple()
          #     iconName: 'star'
          #   }
          ])

  isExpandedByPath: (path) =>
    {expandedItems} = @state.getValue()
    expandedItems.indexOf(path) isnt -1

  toggleExpandItemByPath: (path) =>
    {expandedItems} = @state.getValue()
    isExpanded = @isExpandedByPath path

    if isExpanded
      expandedItems = _clone expandedItems
      expandedItems.splice expandedItems.indexOf(path), 1
      @state.set expandedItems: expandedItems
    else
      @state.set expandedItems: expandedItems.concat [path]

  render: ({currentPath}) =>
    {isOpen, me, menuItems, myEntities, drawerWidth, breakpoint, entity,
      language, windowSize} = @state.getValue()

    entity ?= {}

    console.log 'entity', entity

    translateX = if isOpen then 0 else "-#{drawerWidth}px"
    # adblock plus blocks has-ad
    hasA = false #@model.ad.isVisible({isWebOnly: true}) and
      # windowSize?.height > 880 and
      # not Environment.isMobile()

    renderChild = (child, depth = 0) =>
      {path, title, $chevronIcon, children, expandOnClick} = child
      isSelected = currentPath?.indexOf(path) is 0
      isExpanded = isSelected or @isExpandedByPath(path or title)

      hasChildren = not _isEmpty children
      z 'li.menu-item',
        z 'a.menu-item-link.is-child', {
          className: z.classKebab {isSelected}
          href: path
          onclick: (e) =>
            e.preventDefault()
            if expandOnClick
              expand()
            else
              @model.drawer.close()
              @router.goPath path
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
      z @$drawer,
        $content:
          z '.z-nav-drawer_drawer', {
            className: z.classKebab {hasA}
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
                  #         z @$signInButton,
                  #           isPrimary: true
                  #           isFullWidth: true
                  #           text: @model.l.get 'general.signIn'
                  #           onclick: =>
                  #             @model.overlay.open @$signInOverlay, {data: 'signIn'}
                  #       z '.button',
                  #         z @$joinButton,
                  #           isPrimary: true
                  #           isFullWidth: true
                  #           text: @model.l.get 'general.signUp'
                  #           onclick: =>
                  #             @model.overlay.open @$signInOverlay, {data: 'join'}
                  #     z 'li.divider'
                  #   ]
                  _map menuItems, (menuItem) =>
                    {path, onclick, title, $icon, $chevronIcon, $ripple, isNew,
                      iconName, isDivider, children, expandOnClick
                      color} = menuItem

                    hasChildren = not _isEmpty children

                    if isDivider
                      return z 'li.divider'

                    if menuItem.isDefault
                      isSelected = currentPath is @router.get('home') or
                        (currentPath and currentPath.indexOf(path) is 0)
                    else
                      isSelected = currentPath?.indexOf(path) is 0

                    isExpanded = isSelected or @isExpandedByPath(path or title)

                    expand = (e) =>
                      e?.stopPropagation()
                      e?.preventDefault()
                      @toggleExpandItemByPath path or title

                    z 'li.menu-item', {
                      className: z.classKebab {isSelected}
                    },
                      z 'a.menu-item-link', {
                        href: path
                        style:
                          if color
                            color: color
                        onclick: (e) =>
                          e.preventDefault()
                          if expandOnClick
                            expand()
                          else if onclick
                            onclick()
                          else if path
                            @router.goPath path
                            @model.drawer.close()
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
                          className: z.classKebab {
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

                  unless _isEmpty myEntities
                    z 'li.divider'

                  # z 'li.subhead', @model.l.get 'drawer.otherEntities'
              ]
