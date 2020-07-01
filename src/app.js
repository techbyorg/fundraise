import { z } from 'zorium'
import * as _ from 'lodash-es'

import $sharedApp from 'frontend-shared/app'

import getEntityPage from './pages/entity'
import $loginLinkPage from 'frontend-shared/pages/login_link'
// import $notificationsPage from './pages/notifications'
import $policiesPage from 'frontend-shared/pages/policies'
import $privacyPage from 'frontend-shared/pages/privacy'
import $shellPage from './pages/shell'
import getSearchPage from './pages/search'
import $signInPage from 'frontend-shared/pages/sign_in'
import $tosPage from 'frontend-shared/pages/tos'
import $unsubscribeEmailPage from 'frontend-shared/pages/unsubscribe_email'
import $verifyEmailPage from 'frontend-shared/pages/verify_email'
import $404Page from './pages/404'

const $fundSearchPage = getSearchPage('irsFund')
const $fundPage = getEntityPage('irsFund')
const $nonprofitSearchPage = getSearchPage('irsNonprofit')
const $nonprofitPage = getEntityPage('irsNonprofit')

export default function $app (props) {
  return z($sharedApp, _.defaults({
    routes: {
      // add to lang/paths_en.json
      // <langKey>: $page
      fundByEin: $fundPage,
      fundByEinWithTab: $fundPage,
      loginLink: $loginLinkPage,
      // notifications: $notificationsPage
      nonprofitByEin: $nonprofitPage,
      nonprofitByEinWithTab: $nonprofitPage,
      policies: $policiesPage,
      privacy: $privacyPage,
      // settings: $settingsPage
      home: $fundSearchPage,
      search: $fundSearchPage,
      searchWithFocusAreaAndLocation: $fundSearchPage,
      searchNonprofits: $nonprofitSearchPage,
      searchNonprofitsWithFocusAreaAndLocation: $nonprofitSearchPage,
      shell: $shellPage,
      signIn: $signInPage,
      termsOfService: $tosPage,
      unsubscribeEmail: $unsubscribeEmailPage,
      verifyEmail: $verifyEmailPage,
      fourOhFour: $404Page
    }
  }, props))
}
