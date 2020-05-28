{z} = require 'zorium'
_defaults = require 'lodash/defaults'

$app = require 'frontend-shared/app'

$fundPage = require './pages/fund'
$homePage = require './pages/home'
$orgPage = require './pages/org'
$loginLinkPage = require 'frontend-shared/pages/login_link'
$notificationsPage = require './pages/notifications'
$policiesPage = require 'frontend-shared/pages/policies'
$privacyPage = require 'frontend-shared/pages/privacy'
$shellPage = require './pages/shell'
$searchPage = require './pages/search'
$signInPage = require 'frontend-shared/pages/sign_in'
$tosPage = require 'frontend-shared/pages/tos'
$unsubscribeEmailPage = require 'frontend-shared/pages/unsubscribe_email'
$verifyEmailPage = require 'frontend-shared/pages/verify_email'
$404Page = require './pages/404'

module.exports = App = (props) ->

  console.log 'render app'
  z $app, _defaults {
    routes:
      # add to lang/paths_en.json
      # <langKey>: $page
      fundByEin: $fundPage
      loginLink: $loginLinkPage
      notifications: $notificationsPage
      orgByEin: $orgPage
      policies: $policiesPage
      privacy: $privacyPage
      # settings: $settingsPage
      home: $searchPage
      search: $searchPage
      shell: $shellPage
      signIn: $signInPage
      termsOfService: $tosPage
      unsubscribeEmail: $unsubscribeEmailPage
      verifyEmail: $verifyEmailPage
      fourOhFour: $404Page
  }, props
