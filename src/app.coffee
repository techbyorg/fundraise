{z, classKebab, useStream} = require 'zorium'
HttpHash = require 'http-hash'
_map = require 'lodash/map'
_values = require 'lodash/values'
_flatten = require 'lodash/flatten'
_defaults = require 'lodash/defaults'
RxObservable = require('rxjs/Observable').Observable
require 'rxjs/add/operator/map'
require 'rxjs/add/operator/filter'
require 'rxjs/add/operator/switchMap'
require 'rxjs/add/observable/combineLatest'
require 'rxjs/add/observable/of'
require 'rxjs/add/operator/publishReplay'

$head = require './components/head'
# $navDrawer = require './components/nav_drawer'
$bottomBar = require './components/bottom_bar'
Environment = require './services/environment'

Pages =
  $fundPage: require './pages/fund'
  $homePage: require './pages/home'
  $orgPage: require './pages/org'
  $loginLinkPage: require './pages/login_link'
  $notificationsPage: require './pages/notifications'
  $policiesPage: require './pages/policies'
  $privacyPage: require './pages/privacy'
  $shellPage: require './pages/shell'
  $searchPage: require './pages/search'
  $signInPage: require './pages/sign_in'
  $tosPage: require './pages/tos'
  $unsubscribeEmailPage: require './pages/unsubscribe_email'
  $verifyEmaiLPage: require './pages/verify_email'
  $404Page: require './pages/404'

module.exports = App = (props) ->
  {requests, serverData, model, router, isCrawler} = props

  getRoutes = (breakpoint) ->
    # can have breakpoint (mobile/desktop) specific routes
    routes = new HttpHash()

    route = (routeKeys, pageKey) ->
      Page = Pages[pageKey]
      if typeof routeKeys is 'string'
        routeKeys = [routeKeys]

      paths = _flatten _map routeKeys, (routeKey) ->
        _values model.l.getAllPathsByRouteKey routeKey

      _map paths, (path) ->
        routes.set path, -> Page

    route 'fundByEin', '$fundPage'
    route 'loginLink', '$loginLinkPage'
    route 'notifications', '$notificationsPage'
    route 'orgByEin', '$orgPage'
    route 'policies', '$policiesPage'
    route 'privacy', '$privacyPage'
    route 'settings', '$settingsPage'
    route ['home', 'search'], '$searchPage'
    route 'shell', '$shellPage'
    route 'signIn', '$signInPage'
    route 'termsOfService', '$tosPage'
    route 'unsubscribeEmail', '$unsubscribeEmailPage'
    route 'verifyEmail', '$verifyEmaiLPage'

    route '404', '$404Page'
    routes

  routes = model.window.getBreakpoint().map getRoutes
          .publishReplay(1).refCount()

  userAgent = model.window.getUserAgent()
  isNativeApp = Environment.isNativeApp {userAgent}

  requestsAndRoutes = RxObservable.combineLatest(
    requests, routes, (vals...) -> vals
  )

  isFirstRequest = true
  requests = requestsAndRoutes.map ([req, routes]) ->
    if window? and isFirstRequest and req.query.referrer
      model.user.setReferrer req.query.referrer

    if isFirstRequest and isNativeApp
      path = model.cookie.get('routerLastPath') or req.path
      if window?
        req.path = path # doesn't work server-side
      else
        req = _defaults {path}, req

    # subdomain = router.getSubdomain()
    #
    # if subdomain # equiv to /entitySlug/route
    #   route = routes.get "/#{subdomain}#{req.path}"
    #   if route.handler?() instanceof Pages['$404Page']
    #     route = routes.get req.path
    # else
    route = routes.get req.path

    $page = route.handler?()
    isFirstRequest = false
    {req, route, $page: $page}
  .publishReplay(1).refCount()

  # used for overlay pages
  router.setRequests requests

  # FIXME: memoize all this stuff
  entityStream = requests.switchMap ({route}) ->
    host = serverData?.req?.headers.host or window?.location?.host
    entitySlug = route.params.entitySlug

    if entitySlug
      router.setEntitySlug entitySlug

    # subdomain = router.getSubdomain()
    # if subdomain and subdomain isnt 'staging' and not entitySlug
    #   entitySlug = subdomain

    entitySlug or= model.cookie.get 'lastEntitySlug'

    # FIXME
    # (if entitySlug and entitySlug isnt 'undefined' and entitySlug isnt 'null'
    #   model.entity.getBySlug entitySlug, {autoJoin: false}
    # else
    console.log 'gogogogo'
    (model.entity.getDefaultEntity()
    ).map (entity) ->
      entity or false
  .publishReplay(1).refCount()

  isNativeApp = Environment.isNativeApp {userAgent}

  me = model.user.getMe()

  # requestsAndMe = RxObservable.combineLatest(
  #   requests
  #   me
  #   entity
  #   (vals...) -> vals
  # )

  # used if state / requests fails to work
  $backupPage = if serverData?
    if isNativeApp
      serverPath = model.cookie.get('routerLastPath') or serverData.req.path
    else
      serverPath = serverData.req.path
    getRoutes().get(serverPath).handler?()
  else
    Pages.$404Page

  {request, $backupPage, me, hideDrawer, statusBarData, windowSize,
    $overlays, $tooltip} = useStream ->
    $backupPage: $backupPage
    me: me
    $overlays: model.overlay.get$()
    $tooltip: model.tooltip.get$()
    windowSize: model.window.getSize()
    # hideDrawer: requests.switchMap (request) ->
    #   $page = router.preservedRequest?.$page or request.$page
    #   hideDrawer = $page?.hideDrawer
    #   if hideDrawer?.map
    #   then hideDrawer
    #   else RxObservable.of (hideDrawer or false)
    request: requests.do ({$page, req}) ->
      # FIXME
      # if $page instanceof Pages['$404Page']
      #   serverData?.res?.status? 404

    # authed: requestsAndMe.do ([{$page, req}, me, entity]) ->
    #   isMember = model.user.isMember me
    #   console.log 'redir', entity, $page, isMember
    #   if entity? and $page and not $page.allowGuests and (not isMember or not entity)
    #     console.log 'redir'
    #     if window?
    #       setTimeout -> # give time for router.setEntitySlug
    #         router.go 'onboardByType', {type: 'fund'}
    #       , 0
    #     else
    #       route = router.get 'onboardByType', {type: 'fund'}
    #       serverData?.res?.redirect 302, route


  console.log 'overlays', $overlays

  userAgent = model.window.getUserAgent()
  isIos = Environment.isIos {userAgent}
  isAndroid = Environment.isAndroid {userAgent}
  isFirefox = userAgent?.indexOf('Firefox') isnt -1

  if router.preservedRequest
    $page = router.preservedRequest?.$page
    $overlayPage = request?.$page
    hasBottomBar = $overlayPage.hasBottomBar
  else
    $page = request?.$page or $backupPage
    hasBottomBar = $page?.$bottomBar

  hasOverlayPage = $overlayPage?

  focusTags = ['INPUT', 'TEXTAREA', 'SELECT']

  pageProps = {
    model
    router
    serverData
    entityStream
    # FIXME!
    # $bottomBar: if $page.hasBottomBar then z $bottomBar, {
    #   model, router, requests, entityStream, serverData
    # }
    requests: requests
    # .filter ({$page}) ->
    #   # FIXME
    #   $page instanceof Page
  }

  $body =
    z '#zorium-root', {
      className: classKebab {isIos, isAndroid, isFirefox, hasOverlayPage}
      onclick: if Environment.isIos()
        (e) ->
          focusTag = document.activeElement.tagName
          if focusTag in focusTags and not (e.target.tagName in focusTags)
            document.activeElement.blur()
    },
      # FIXME
      # used for screenshotting
      if $page?.isPlain
        z '.z-root',
          z '.content', {
            style:
              height: "#{windowSize.height}px"
          },
            z $page, pageProps
      else
        z '.z-root',
          # unless hideDrawer
          #   z $navDrawer, {
          #     model, router, entityStream, currentPath: request?.req.path
          #   }

          z '.content', {
            style:
              height: "#{windowSize.height}px"
          },
            z '.page', {key: 'page'},
              z $page, pageProps

          if $overlayPage
            z '.overlay-page', {
              key: 'overlay-page'
              style:
                height: "#{windowSize.height}px"
            },
              z $overlayPage, pageProps

          z '#overlays-portal',
            # legacy overlays
            _map $overlays, ($overlay) ->
              $overlay

          # z $tooltip

          # used in color.coffee to detect support
          z '#css-variable-test',
            style:
              display: 'none'
              backgroundColor: 'var(--test-color)'

  if window?
    $body
  else
    z 'html', {
      lang: 'en'
    },
      z $head, {
        model
        router
        requests
        serverData
        entityStream
        isPlain: $page?.isPlain
        meta: $page?.getMeta?()
      }
      # FIXME: rm options
      z 'body', {}, $body
