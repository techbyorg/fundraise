Exoid = require 'exoid'
_isEmpty = require 'lodash/isEmpty'
_isPlainObject = require 'lodash/isPlainObject'
_defaults = require 'lodash/defaults'
_merge = require 'lodash/merge'
_pick = require 'lodash/pick'
_map = require 'lodash/map'
_zipWith = require 'lodash/zipWith'
_differenceWith = require 'lodash/differenceWith'
_isEqual = require 'lodash/isEqual'
_keys = require 'lodash/keys'
RxBehaviorSubject = require('rxjs/BehaviorSubject').BehaviorSubject
RxObservable = require('rxjs/Observable').Observable
require 'rxjs/add/observable/combineLatest'
require 'rxjs/add/observable/of'
require 'rxjs/add/operator/take'

Auth = require './auth'
AdditionalScript = require './additional_script'
Cookie = require './cookie'
Entity = require './entity'
EntityUser = require './entity_user'
Experiment = require './experiment'
Image = require './image'
IrsFund = require './irs_fund'
IrsFund990 = require './irs_fund_990'
IrsOrg = require './irs_org'
IrsOrg990 = require './irs_org_990'
IrsPerson = require './irs_person'
Language = require './language'
LoginLink = require './login_link'
Notification = require './notification'
OfflineData = require './offline_data'
PushToken = require './push_token'
Subscription = require './subscription'
Time = require './time'
User = require './user'
UserData = require './user_data'
UserSettings = require './user_settings'
Drawer = require './drawer'
Overlay = require './overlay'
Tooltip = require './tooltip'
Window = require './window'
request = require '../services/request'

config = require '../config'

SERIALIZATION_KEY = 'MODEL'
# SERIALIZATION_EXPIRE_TIME_MS = 1000 * 10 # 10 seconds

module.exports = class Model
  constructor: (options) ->
    {serverHeaders, io, @portal, language,
      initialCookies, setCookie, host} = options
    serverHeaders ?= {}

    cache = window?[SERIALIZATION_KEY] or {}
    window?[SERIALIZATION_KEY] = null
    # maybe this means less memory used for long caches?
    document?.querySelector('.model')?.innerHTML = ''

    # isExpired = if serialization.expires?
    #   # Because of potential clock skew we check around the value
    #   delta = Math.abs(Date.now() - serialization.expires)
    #   delta > SERIALIZATION_EXPIRE_TIME_MS
    # else
    #   true
    # cache = if isExpired then {} else serialization
    @isFromCache = not _isEmpty cache

    userAgent = serverHeaders['user-agent'] or navigator?.userAgent

    ioEmit = (event, opts) =>
      accessToken = @cookie.get 'accessToken'
      io.emit event, _defaults {accessToken, userAgent}, opts

    proxy = (url, opts) =>
      accessToken = @cookie.get 'accessToken'
      proxyHeaders =  _pick serverHeaders, [
        'cookie'
        'user-agent'
        'accept-language'
        'x-forwarded-for'
      ]
      request url, _merge {
        responseType: 'json'
        query: if accessToken? then {accessToken} else {}
        headers: if _isPlainObject opts?.body
          _merge {
            # Avoid CORS preflight
            'Content-Type': 'text/plain'
          }, proxyHeaders
        else
          proxyHeaders
      }, opts

    if navigator?.onLine
      offlineCache = null
    else
      offlineCache = try
        JSON.parse localStorage?.offlineCache
      catch
        {}

    @initialCache = _defaults offlineCache, cache.exoid

    @exoid = new Exoid
      ioEmit: ioEmit
      io: io
      cache: @initialCache
      isServerSide: not window?

    pushToken = new RxBehaviorSubject null

    @cookie = new Cookie {initialCookies, setCookie, host}
    @l = new Language {language, @cookie}
    @overlay = new Overlay()

    @auth = new Auth {@exoid, @cookie, pushToken, @l, userAgent, @portal}

    @offlineData = new OfflineData {@exoid, @portal, @statusBar, @l}

    @additionalScript = new AdditionalScript()
    @entity = new Entity {@auth}
    @entityUser = new EntityUser {@auth}
    @experiment = new Experiment {@cookie}
    @image = new Image {@additionalScript}
    @irsFund = new IrsFund {@auth}
    @irsFund990 = new IrsFund990 {@auth}
    @irsOrg = new IrsOrg {@auth}
    @irsOrg990 = new IrsOrg990 {@auth}
    @irsPerson = new IrsPerson {@auth}
    @loginLink = new LoginLink {@auth}
    @notification = new Notification {@auth}
    @pushToken = new PushToken {@auth, pushToken}
    @subscription = new Subscription {@auth}
    @time = new Time {@auth}
    @user = new User {@auth, proxy, @exoid, @cookie, @l, @overlay, @portal, @router}
    @userData = new UserData {@auth}
    @userSettings = new UserSettings {@auth}

    @drawer = new Drawer()
    @tooltip = new Tooltip()
    @portal?.setModels {
      @user, @pushToken, @l, @installOverlay, @overlay
    }
    @window = new Window {@cookie, @experiment, userAgent}

  # after page has loaded, refetch all initial (cached) requests to verify they're still up-to-date
  validateInitialCache: =>
    cache = @initialCache
    @initialCache = null

    # could listen for postMessage from service worker to see if this is from
    # cache, then validate data
    requests = _map cache, (result, key) =>
      req = try
        JSON.parse key
      catch
        RxObservable.of null

      if req.path
        @auth.stream req.path, req.body, {ignoreCache: true} #, options

    # TODO: seems to use anon cookie for this. not sure how to fix...
    # i guess keep initial cookie stored and run using that?

    # so need to handle the case where the cookie changes between server-side
    # cache and the actual get (when user doesn't exist from exoid, but cookie gets user)

    RxObservable.combineLatest(
      requests, (vals...) -> vals
    )
    .take(1).subscribe (responses) =>
      responses = _zipWith responses, _keys(cache), (response, req) ->
        {req, response}
      cacheArray = _map cache, (response, req) ->
        {req, response}
      # see if our updated responses differ from the cached data.
      changedReqs = _differenceWith(responses, cacheArray, _isEqual)
      # update with new values
      _map changedReqs, ({req, response}) =>
        console.log 'OUTDATED EXOID:', req, 'replacing...', response
        @exoid.setDataCache req, response

      # there's a change this will be invalidated every time
      # eg. if we add some sort of timer / visitCount to user.getMe
      # i'm not sure if that's a bad thing or not. some people always
      # load from cache then update, and this would basically be the same
      unless _isEmpty changedReqs
        console.log 'invalidating html cache...'
        @portal.call 'cache.deleteHtmlCache'
        # FIXME TODO invalidate in service worker


  wasCached: => @isFromCache

  dispose: =>
    @time.dispose()
    @exoid.disposeAll()

  getSerializationStream: =>
    @exoid.getCacheStream()
    .map (exoidCache) ->
      string = JSON.stringify({
        exoid: exoidCache
        # problem with this is clock skew
        # expires: Date.now() + SERIALIZATION_EXPIRE_TIME_MS
      }).replace /<\/script/gi, '<\\/script'
      "window['#{SERIALIZATION_KEY}']=#{string};"
