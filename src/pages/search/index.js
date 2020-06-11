import {z, useMemo} from 'zorium'
import * as rx from 'rxjs/operators'

import $appBar from 'frontend-shared/components/app_bar'
import useMeta from 'frontend-shared/services/use_meta'

import $search from '../../components/search'
import config from '../../config'

if window?
  require './index.styl'

export default $searchPage = ({requestsStream}) ->
  {nteeStream, locationStream} = useMemo ->
    {
      nteeStream: requestsStream.pipe rx.map ({route}) ->
        route.params.ntee
      locationStream: requestsStream.pipe rx.map ({route}) ->
        route.params.location
    }
  , []

  useMeta ->
    {
      openGraph:
        image: 'https://fdn.uno/d/images/techby/home/fundraise_thumbnail.png'
    }
  , []

  z '.p-search',
    z $appBar, {
      hasLogo: true
      # $topLeftButton: z $buttonBack, {color: colors.$header500Icon}
    }
    z $search, {
      nteeStream, locationStream
    }
