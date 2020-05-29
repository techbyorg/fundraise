import {z} from 'zorium'
RxBehaviorSubject = require('rxjs/BehaviorSubject').BehaviorSubject

import $appBar from 'frontend-shared/components/app_bar'

import $search from '../../components/search'
import config from '../../config'

if window?
  require './index.styl'

export default $searchPage = ->
  z '.p-search',
    z $appBar, {
      hasLogo: true
      # $topLeftButton: z $buttonBack, {color: colors.$header500Icon}
    }
    z $search
