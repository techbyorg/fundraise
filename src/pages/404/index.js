/* eslint-disable
    no-unused-vars,
*/
// TODO: This file was created by bulk-decaffeinate.
// Fix any style issues and re-enable lint.
import { z, useContext } from 'zorium'

import $appBar from 'frontend-shared/components/app_bar'
import $buttonMenu from 'frontend-shared/components/button_menu'
import $button from 'frontend-shared/components/button'

import colors from '../../colors'
import context from '../../context'
import config from '../../config'

export default function $404Page (props) {
  const { requestsStream, serverData, entity } = props
  const { lang, router } = useContext(context)

  return z('.p-404',
    z($appBar, {
      title: lang.get('404Page.text'),
      $topLeftButton: z($buttonMenu, { color: colors.$header500Icon })
    }),
    z('.content', {
      style: {
        padding: '16px'
      }
    },
    lang.get('404Page.text'),
    z('br'),
    '(╯°□°)╯︵ ┻━┻',
    z($button, {
      text: lang.get('general.back'),
      onclick () {
        return router.goPath('/')
      }
    }
    )
    )
  )
}
