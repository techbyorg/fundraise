import { z, useContext } from 'zorium'

import $appBar from 'frontend-shared/components/app_bar'
import $buttonMenu from 'frontend-shared/components/button_menu'
import $notifications from 'frontend-shared/components/notifications'

import context from '../../context'
import colors from '../../colors'

if (typeof window !== 'undefined') { require('./index.styl') }

export default function $notificationsPage () {
  const { lang } = useContext(context)

  return z('.p-notifications', [
    z($appBar, {
      title: lang.get('general.notifications'),
      style: 'primary',
      $topLeftButton:
        z($buttonMenu, { color: colors.$header500Icon })
    }),
    z($notifications)
  ])
}
