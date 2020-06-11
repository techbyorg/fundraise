/* eslint-disable
    no-unused-vars,
*/
// TODO: This file was created by bulk-decaffeinate.
// Fix any style issues and re-enable lint.
import { z } from 'zorium'
import * as _ from 'lodash-es'

import $sharedApp from 'frontend-shared/app'

import $fundPage from './pages/fund'
import $homePage from './pages/home'
import $orgPage from './pages/org'
import $loginLinkPage from 'frontend-shared/pages/login_link'
// import $notificationsPage from './pages/notifications'
import $policiesPage from 'frontend-shared/pages/policies'
import $privacyPage from 'frontend-shared/pages/privacy'
import $shellPage from './pages/shell'
import $searchPage from './pages/search'
import $signInPage from 'frontend-shared/pages/sign_in'
import $tosPage from 'frontend-shared/pages/tos'
import $unsubscribeEmailPage from 'frontend-shared/pages/unsubscribe_email'
import $verifyEmailPage from 'frontend-shared/pages/verify_email'
import $404Page from './pages/404'
let $app

export default $app = props => z($sharedApp, _.defaults({
  routes: {
    // add to lang/paths_en.json
    // <langKey>: $page
    fundByEin: $fundPage,
    fundByEinWithTab: $fundPage,
    loginLink: $loginLinkPage,
    // notifications: $notificationsPage
    orgByEin: $orgPage,
    policies: $policiesPage,
    privacy: $privacyPage,
    // settings: $settingsPage
    home: $searchPage,
    search: $searchPage,
    searchWithFocusAreaAndLocation: $searchPage,
    shell: $shellPage,
    signIn: $signInPage,
    termsOfService: $tosPage,
    unsubscribeEmail: $unsubscribeEmailPage,
    verifyEmail: $verifyEmailPage,
    fourOhFour: $404Page
  }
}, props)
)
