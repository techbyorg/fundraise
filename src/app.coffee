z = require 'zorium'
HttpHash = require 'http-hash'
_forEach = require 'lodash/forEach'
_map = require 'lodash/map'
_values = require 'lodash/values'
_flatten = require 'lodash/flatten'
_isEmpty = require 'lodash/isEmpty'
_defaults = require 'lodash/defaults'
RxObservable = require('rxjs/Observable').Observable
RxBehaviorSubject = require('rxjs/BehaviorSubject').BehaviorSubject
require 'rxjs/add/operator/map'
require 'rxjs/add/operator/filter'
require 'rxjs/add/operator/switchMap'
require 'rxjs/add/observable/combineLatest'
require 'rxjs/add/observable/of'
require 'rxjs/add/operator/publishReplay'

Head = require './components/head'
NavDrawer = require './components/nav_drawer'
BottomBar = require './components/bottom_bar'
Environment = require './services/environment'
config = require './config'
colors = require './colors'

Pages =
  HomePage: require './pages/home'
  LoginLinkPage: require './pages/login_link'
  NotificationsPage: require './pages/notifications'
  PoliciesPage: require './pages/policies'
  PrivacyPage: require './pages/privacy'
  ShellPage: require './pages/shell'
  SignInPage: require './pages/sign_in'
  TosPage: require './pages/tos'
  UnsubscribeEmailPage: require './pages/unsubscribe_email'
  VerifyEmailPage: require './pages/verify_email'
  FourOhFourPage: require './pages/404'

TIME_UNTIL_ADD_TO_HOME_PROMPT_MS = 90000 # 1.5 min

module.exports = class App
  constructor: (options) ->
    {requests, @serverData, @model, @router, @isCrawler} = options
    @$cachedPages = []
    routes = @model.window.getBreakpoint().map @getRoutes
            .publishReplay(1).refCount()

    userAgent = @model.window.getUserAgent()
    isNativeApp = Environment.isNativeApp {userAgent}

    requestsAndRoutes = RxObservable.combineLatest(
      requests, routes, (vals...) -> vals
    )

    isFirstRequest = true
    @requests = requestsAndRoutes.map ([req, routes]) =>
      if window? and isFirstRequest and req.query.referrer
        @model.user.setReferrer req.query.referrer

      if isFirstRequest and isNativeApp
        path = @model.cookie.get('routerLastPath') or req.path
        if window?
          req.path = path # doesn't work server-side
        else
          req = _defaults {path}, req

      # subdomain = @router.getSubdomain()
      #
      # if subdomain # equiv to /entitySlug/route
      #   route = routes.get "/#{subdomain}#{req.path}"
      #   if route.handler?() instanceof Pages['FourOhFourPage']
      #     route = routes.get req.path
      # else
      route = routes.get req.path

      $page = route.handler?()
      isFirstRequest = false
      {req, route, $page: $page}
    .publishReplay(1).refCount()

    # used for overlay pages
    @router.setRequests @requests

    @entity = @requests.switchMap ({route}) =>
      host = @serverData?.req?.headers.host or window?.location?.host
      entitySlug = route.params.entitySlug

      if entitySlug
        @router.setEntitySlug entitySlug

      # subdomain = @router.getSubdomain()
      # if subdomain and subdomain isnt 'staging' and not entitySlug
      #   entitySlug = subdomain

      entitySlug or= @model.cookie.get 'lastEntitySlug'

      (if entitySlug and entitySlug isnt 'undefined' and entitySlug isnt 'null'
        @model.entity.getBySlug entitySlug, {autoJoin: false}
      else
        @model.entity.getDefaultEntity {autoJoin: false}
      ).map (entity) ->
        entity or false
    .publishReplay(1).refCount()

    isNativeApp = Environment.isNativeApp {userAgent}

    @$navDrawer = new NavDrawer {@model, @router, @entity}
    @$bottomBar = new BottomBar {
      @model, @router, @requests, @entity, @serverData
    }
    @$head = new Head({
      @model
      @router
      @requests
      @serverData
      @entity
    })

    me = @model.user.getMe()

    requestsAndMe = RxObservable.combineLatest(
      @requests
      me
      @entity
      (vals...) -> vals
    )

    # used if state / requests fails to work
    $backupPage = if @serverData?
      if isNativeApp
        serverPath = @model.cookie.get('routerLastPath') or @serverData.req.path
      else
        serverPath = @serverData.req.path
      @getRoutes().get(serverPath).handler?()
    else
      null

    $backupPage or= new Pages.FourOhFourPage {
      @model, @router, @serverData
    }

    @state = z.state {
      $backupPage: $backupPage
      me: me
      $overlays: @model.overlay.get$()
      $tooltip: @model.tooltip.get$()
      windowSize: @model.window.getSize()
      hideDrawer: @requests.switchMap (request) =>
        $page = @router.preservedRequest?.$page or request.$page
        hideDrawer = $page?.hideDrawer
        if hideDrawer?.map
        then hideDrawer
        else RxObservable.of (hideDrawer or false)
      request: @requests.do ({$page, req}) ->
        if $page instanceof Pages['FourOhFourPage']
          @serverData?.res?.status? 404
      # authed: requestsAndMe.do ([{$page, req}, me, entity]) =>
      #   isMember = @model.user.isMember me
      #   console.log 'redir', entity, $page, isMember
      #   if entity? and $page and not $page.allowGuests and (not isMember or not entity)
      #     console.log 'redir'
      #     if window?
      #       setTimeout => # give time for router.setEntitySlug
      #         @router.go 'onboardByType', {type: 'fund'}
      #       , 0
      #     else
      #       route = @router.get 'onboardByType', {type: 'fund'}
      #       @serverData?.res?.redirect 302, route
    }

  getRoutes: (breakpoint) =>
    # can have breakpoint (mobile/desktop) specific routes
    routes = new HttpHash()
    languages = @model.l.getAllUrlLanguages()

    route = (routeKeys, pageKey) =>
      Page = Pages[pageKey]
      if typeof routeKeys is 'string'
        routeKeys = [routeKeys]

      paths = _flatten _map routeKeys, (routeKey) =>
        _values @model.l.getAllPathsByRouteKey routeKey

      _map paths, (path) =>
        routes.set path, =>
          unless @$cachedPages[pageKey]
            @$cachedPages[pageKey] = new Page({
              @model
              @router
              @serverData
              @entity
              $bottomBar: if Page.hasBottomBar then @$bottomBar
              requests: @requests.filter ({$page}) ->
                $page instanceof Page
            })
          return @$cachedPages[pageKey]


    route 'loginLink', 'LoginLinkPage'
    route 'signIn', 'SignInPage'
    route 'notifications', 'NotificationsPage'
    route 'policies', 'PoliciesPage'
    route 'privacy', 'PrivacyPage'
    route 'settings', 'SettingsPage'
    route 'shell', 'ShellPage'
    route 'termsOfService', 'TosPage'
    route 'unsubscribeEmail', 'UnsubscribeEmailPage'
    route 'verifyEmail', 'VerifyEmailPage'

    route '404', 'FourOhFourPage'
    routes

  render: =>
    {request, $backupPage, me, hideDrawer, statusBarData, windowSize,
      $overlays, $tooltip} = @state.getValue()

    # console.log '======== RENDER =========='

    userAgent = @model.window.getUserAgent()
    isIos = Environment.isIos {userAgent}
    isAndroid = Environment.isAndroid {userAgent}
    isFirefox = userAgent?.indexOf('Firefox') isnt -1
    isNative = Environment.isNativeApp {userAgent}
    isStatusBarVisible = Boolean statusBarData

    if @router.preservedRequest
      $page = @router.preservedRequest?.$page
      $overlayPage = request?.$page
      hasBottomBar = $overlayPage.hasBottomBar
    else
      $page = request?.$page or $backupPage
      hasBottomBar = $page?.$bottomBar

    hasOverlayPage = $overlayPage?

    focusTags = ['INPUT', 'TEXTAREA', 'SELECT']

    z 'html', {
      attributes:
        lang: 'en'
    },
      z @$head, {isPlain: $page?.isPlain, meta: $page?.getMeta?()}
      z 'body',
        z '#zorium-root', {
          className: z.classKebab {isIos, isAndroid, isFirefox, hasOverlayPage}
          onclick: if Environment.isIos()
            (e) ->
              focusTag = document.activeElement.tagName
              if focusTag in focusTags and not (e.target.tagName in focusTags)
                document.activeElement.blur()
        },
          # used for screenshotting
          if $page?.isPlain
            z '.z-root',
              z '.content', {
                style:
                  height: "#{windowSize.height}px"
              }, $page
          else
            z '.z-root',
              unless hideDrawer
                z @$navDrawer, {currentPath: request?.req.path}

              z '.content', {
                style:
                  height: "#{windowSize.height}px"
              },
                if isStatusBarVisible
                  if statusBarData.type is 'snack'
                    z @$snackBar, {hasBottomBar}
                  else
                    z @$statusBar
                z '.page', {key: 'page'},
                  $page

              if $overlayPage
                z '.overlay-page', {
                  key: 'overlay-page'
                  style:
                    height: "#{windowSize.height}px"
                },
                  z $overlayPage

              _map $overlays, ($overlay) ->
                z $overlay

              z $tooltip

              # used in color.coffee to detect support
              z '#css-variable-test',
                style:
                  display: 'none'
                  backgroundColor: 'var(--test-color)'
