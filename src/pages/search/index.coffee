{z} = require 'zorium'
RxBehaviorSubject = require('rxjs/BehaviorSubject').BehaviorSubject
import _map from 'lodash/map'

import $appBar from 'frontend-shared/components/app_bar'

import $search from '../../components/search'
import config from '../../config'

if window?
  require './index.styl'

module.exports = $searchPage = ->
  z '.p-search',
    z $appBar, {
      hasLogo: true
      # $topLeftButton: z $buttonBack, {color: colors.$header500Icon}
    }
    z $search
