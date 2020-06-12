import { z } from 'zorium'

import $spinner from 'frontend-shared/components/spinner'

if (typeof window !== 'undefined') { require('./index.styl') }

export default function $homePage () {
  return z('.p-home', $spinner)
}
