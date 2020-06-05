import {z} from 'zorium'

import $appBar from 'frontend-shared/components/app_bar'
import useMeta from 'frontend-shared/services/use_meta'

import $search from '../../components/search'
import config from '../../config'

if window?
  require './index.styl'

export default $searchPage = ->
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
    z $search
