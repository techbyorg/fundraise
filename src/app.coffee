{z, classKebab, useMemo, useStream} = require 'zorium'
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
GlobalContext = require './context'

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


getRoutes = ({breakpoint, lang}) ->
  # can have breakpoint (mobile/desktop) specific routes
  routes = new HttpHash()

  route = (routeKeys, pageKey) ->
    Page = Pages[pageKey]
    if typeof routeKeys is 'string'
      routeKeys = [routeKeys]

    paths = _flatten _map routeKeys, (routeKey) ->
      _values lang.getAllPathsByRouteKey routeKey

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


module.exports = App = (props) ->
  {requestsStream, serverData, model, router, portal,
    lang, cookie, browser, isCrawler} = props

  {routesStream, requestsStream, entityStream} = useMemo ->
    routesStream = browser.getBreakpoint().map (breakpoint) ->
      getRoutes {breakpoint, lang}
    .publishReplay(1).refCount()

    requestsStreamAndRoutesStream = RxObservable.combineLatest(
      requestsStream, routesStream, (vals...) -> vals
    )

    requestsStream = requestsStreamAndRoutesStream.map ([req, routes]) ->
      console.log 'req', req
      if window? and isFirstRequest and req.query.referrer
        model.user.setReferrer req.query.referrer

      if isFirstRequest and isNativeApp
        path = cookie.get('routerLastPath') or req.path
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

    {
      routesStream: routesStream
      requestsStream: requestsStream
      entityStream: requestsStream.switchMap ({route}) ->
        host = serverData?.req?.headers.host or window?.location?.host
        entitySlug = route.params.entitySlug

        if entitySlug
          router.setEntitySlug entitySlug

        # subdomain = router.getSubdomain()
        # if subdomain and subdomain isnt 'staging' and not entitySlug
        #   entitySlug = subdomain

        entitySlug or= cookie.get 'lastEntitySlug'

        # FIXME
        # (if entitySlug and entitySlug isnt 'undefined' and entitySlug isnt 'null'
        #   model.entity.getBySlug entitySlug, {autoJoin: false}
        # else
        console.log 'gogogogo'
        (model.entity.getDefaultEntity()
        ).map (entity) ->
          entity or false
      .publishReplay(1).refCount()

    }
  , []

  userAgent = browser.getUserAgent()
  isNativeApp = Environment.isNativeApp {userAgent}

  isFirstRequest = true

  # used for overlay pages
  router.setRequests requestsStream


  isNativeApp = Environment.isNativeApp {userAgent}

  # me = model.user.getMe()
  # TODO if reimplementing, move to memo
  # requestsStreamAndMe = RxObservable.combineLatest(
  #   requestsStream
  #   me
  #   entity
  #   (vals...) -> vals
  # )

  # used if state / requestsStream fails to work
  $backupPage = if serverData?
    if isNativeApp
      serverPath = cookie.get('routerLastPath') or serverData.req.path
    else
      serverPath = serverData.req.path
    getRoutes({lang}).get(serverPath).handler?()
  else
    Pages.$404Page

  {request, $backupPage, me, hideDrawer, statusBarData, windowSize,
    $overlays, $tooltip} = useStream ->
    $backupPage: $backupPage
    me: me
    $overlays: model.overlay.get$()
    $tooltip: model.tooltip.get$()
    windowSize: browser.getSize()
    # hideDrawer: requestsStream.switchMap (request) ->
    #   $page = router.preservedRequest?.$page or request.$page
    #   hideDrawer = $page?.hideDrawer
    #   if hideDrawer?.map
    #   then hideDrawer
    #   else RxObservable.of (hideDrawer or false)
    request: requestsStream.do (request) ->
      if request.$page is Pages.$404Page
        serverData?.res?.status? 404

    # authed: requestsStreamAndMe.do ([{$page, req}, me, entity]) ->
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


  console.log 'overlay', request, $overlays

  userAgent = browser.getUserAgent()
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
    serverData
    entityStream
    # FIXME!
    # $bottomBar: if $page.hasBottomBar then z $bottomBar, {
    #   model, router, requestsStream, entityStream, serverData
    # }
    requestsStream: requestsStream.filter (request) ->
      request.$page is $page
  }

  $body =
    z '#zorium-root', {
      key: props.key
      className: classKebab {isIos, isAndroid, isFirefox, hasOverlayPage}
      onclick: if Environment.isIos()
        (e) ->
          focusTag = document.activeElement.tagName
          if focusTag in focusTags and not (e.target.tagName in focusTags)
            document.activeElement.blur()
    },
      z '.z-root',
        # unless hideDrawer
        #   z $navDrawer, {
        #     entityStream, currentPath: request?.req.path
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

  z GlobalContext.Provider, {
    value: {
      model, router, portal, lang, cookie, browser
    }
  },
    if window?
      $body
    else
      z 'html', {
        lang: 'en'
      },
        z $head, {
          requestsStream
          serverData
          entityStream
          # FIXME
          meta: $page?.getMeta?()
        }
        z 'body', $body
