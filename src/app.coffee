{z} = require 'zorium'
import _defaults from 'lodash/defaults'

import $sharedApp from 'frontend-shared/app'

import $fundPage from './pages/fund'
import $homePage from './pages/home'
import $orgPage from './pages/org'
import $loginLinkPage from 'frontend-shared/pages/login_link'
import $notificationsPage from './pages/notifications'
import $policiesPage from 'frontend-shared/pages/policies'
import $privacyPage from 'frontend-shared/pages/privacy'
import $shellPage from './pages/shell'
import $searchPage from './pages/search'
import $signInPage from 'frontend-shared/pages/sign_in'
import $tosPage from 'frontend-shared/pages/tos'
import $unsubscribeEmailPage from 'frontend-shared/pages/unsubscribe_email'
import $verifyEmailPage from 'frontend-shared/pages/verify_email'
import $404Page from './pages/404'

module.exports = $app = (props) ->

  z $sharedApp, _defaults {
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
