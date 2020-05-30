# process.env.* is replaced at run-time with * environment variable
# Note that simply env.* is not replaced, and thus suitible for private config

import * as _ from 'lodash-es'
import assertNoneMissing from 'assert-none-missing'

import colors from './colors'

# Don't let server environment variables leak into client code
serverEnv = process.env

HOST = process.env.FRONTEND_HOST or '127.0.0.1'
HOSTNAME = HOST.split(':')[0]

URL_REGEX_STR = '(\\bhttps?://[-A-Z0-9+&@#/%?=~_|!:,.;]*[A-Z0-9+&@#/%=~_|])'
STICKER_REGEX_STR = '(:[a-z_]+:)'
IMAGE_REGEX_STR = '(\\!\\[(.*?)\\]\\((.*?)\\=([0-9.]+)x([0-9.]+)\\))'
IMAGE_REGEX_BASE_STR = '(\\!\\[(?:.*?)\\]\\((?:.*?)\\))'
LOCAL_IMAGE_REGEX_STR =
  '(\\!\\[(.*?)\\]\\(local://(.*?) \\=([0-9.]+)x([0-9.]+)\\))'
MENTION_REGEX_STR = '\\@[a-zA-Z0-9_-]+'
YOUTUBE_ID_REGEX_STR =
  '(?:youtube\\.com\\/(?:[^\\/]+\\/.+\\/|(?:v|e(?:mbed)?)\\/|.*[?&]v=)|youtu\\.be\\/)([^"&?\\/ ]{11})'

ONE_HOUR_SECONDS = 3600 * 1
TWO_HOURS_SECONDS = 3600 * 2
THREE_HOURS_SECONDS = 3600 * 3
FOUR_HOURS_SECONDS = 3600 * 4
EIGHT_HOURS_SECONDS = 3600 * 8
ONE_DAY_SECONDS = 3600 * 24 * 1
TWO_DAYS_SECONDS = 3600 * 24 * 2
THREE_DAYS_SECONDS = 3600 * 24 * 3

API_URL =
  serverEnv.BACKEND_API_URL or # server
  process.env.PUBLIC_BACKEND_API_URL # client

DEV_USE_HTTPS = process.env.DEV_USE_HTTPS and process.env.DEV_USE_HTTPS isnt '0'

isUrl = API_URL.indexOf('/') isnt -1
if isUrl
  API_HOST_ARRAY = API_URL.split('/')
  API_HOST = API_HOST_ARRAY[0] + '//' + API_HOST_ARRAY[2]
  API_PATH = API_URL.replace API_HOST, ''
else
  API_HOST = API_URL
  API_PATH = ''
# All keys must have values at run-time (value may be null)
isomorphic =
  APP_KEY: 'fundraise'
  LANGUAGES: ['en']

  # ALSO IN backend
  EMPTY_UUID: '00000000-0000-0000-0000-000000000000'
  DEFAULT_PERMISSIONS:
    readMessage: true
    manageChannel: false
    sendMessage: true
    sendLink: true
    sendImage: true
  DEFAULT_NOTIFICATIONS:
    conversationMessage: true
    conversationMention: true
  CDN_URL: 'https://fdn.uno/d/images' # FIXME
  # d folder has longer cache
  SCRIPTS_CDN_URL: 'https://fdn.uno/d/scripts' # FIXME
  USER_CDN_URL: 'https://fdn.uno/images' # FIXME
  IOS_APP_URL: 'FIXME' # FIXME
  GOOGLE_PLAY_APP_URL:
    'FIXME' # FIXME
  HOST: HOST
  API_URL: API_URL
  PUBLIC_API_URL: process.env.PUBLIC_BACKEND_API_URL
  API_HOST: API_HOST
  API_PATH: API_PATH
  # also in free-roam
  DEFAULT_PERMISSIONS: {}
  DEFAULT_NOTIFICATIONS: {}
  FIREBASE:
    API_KEY: process.env.FIREBASE_API_KEY
    AUTH_DOMAIN: process.env.FIREBASE_AUTH_DOMAIN
    DATABASE_URL: process.env.FIREBASE_DATABASE_URL
    PROJECT_ID: process.env.FIREBASE_PROJECT_ID
    MESSAGING_SENDER_ID: process.env.FIREBASE_MESSAGING_SENDER_ID
  DEV_USE_HTTPS: DEV_USE_HTTPS
  AUTH_COOKIE: 'accessToken'
  ENV:
    serverEnv.NODE_ENV or
    process.env.NODE_ENV
  ENVS:
    DEV: 'development'
    PROD: 'production'
    TEST: 'test'

  NTEE_MAJOR_COLORS:
    A: "#a9a9a9"
    B: "#2f4f4f"
    C: "#556b2f"
    D: "#8b4513"
    E: "#483d8b"
    F: "#3cb371"
    G: "#4682b4"
    H: "#000080"
    I: "#9acd32"
    J: "#8b008b"
    K: "#ff4500"
    L: "#00ced1"
    M: "#ffa500"
    N: "#ffff00"
    O: "#7cfc00"
    P: "#8a2be2"
    Q: "#00ff7f"
    R: "#dc143c"
    S: "#0000ff"
    T: "#ff00ff"
    U: "#1e90ff"
    V: "#db7093"
    W: "#eee8aa"
    X: "#ff1493"
    Y: "#ffa07a"
    Z: "#ee82ee"

# Server only
# All keys must have values at run-time (value may be null)
PORT = serverEnv.FRONTEND_PORT or 3000
WEBPACK_DEV_PORT = serverEnv.WEBPACK_DEV_PORT or parseInt(PORT) + 1
WEBPACK_DEV_PROTOCOL = if DEV_USE_HTTPS then 'https://' else 'http://'

server =
  PORT: PORT

  # Development
  WEBPACK_DEV_PORT: WEBPACK_DEV_PORT
  WEBPACK_DEV_PROTOCOL: WEBPACK_DEV_PROTOCOL
  WEBPACK_DEV_URL: serverEnv.WEBPACK_DEV_URL or
    "#{WEBPACK_DEV_PROTOCOL}#{HOSTNAME}:#{WEBPACK_DEV_PORT}"
  SELENIUM_TARGET_URL: serverEnv.SELENIUM_TARGET_URL or null
  REMOTE_SELENIUM: serverEnv.REMOTE_SELENIUM is '1'
  SELENIUM_BROWSER: serverEnv.SELENIUM_BROWSER or 'chrome'
  SAUCE_USERNAME: serverEnv.SAUCE_USERNAME or null
  SAUCE_ACCESS_KEY: serverEnv.SAUCE_ACCESS_KEY or null

assertNoneMissing isomorphic
if window?
  # TODO: esm?
  config = isomorphic
else
  assertNoneMissing server
  # TODO: esm?
  config = _.merge isomorphic, server

export default config
