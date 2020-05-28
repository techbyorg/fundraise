import {z, useContext, useStream} from 'zorium'

import $appBar from 'frontend-shared/components/app_bar'
import $buttonMenu from 'frontend-shared/components/button_menu'
import $spinner from 'frontend-shared/components/spinner'

import colors from '../../colors'
import context from '../../context'
import config from '../../config'

if window?
  require './index.styl'

# generic page that gets loaded from cache for any page w/o a specific shell
export default $shellPage = ({requestsStream}) ->
  {model} = useContext context
  # subscribe so they're in exoid cache
  {} = useStream ->
    me: model.user.getMe()

  z '.p-shell',
    z $appBar, {
      title: ''
      style: 'primary'
      $topLeftButton:
        z $buttonMenu, {color: colors.$header500Icon}
    }
    z '.spinner',
      $spinner
