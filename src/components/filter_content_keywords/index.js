import { z } from 'zorium'

import $input from 'frontend-shared/components/input'

if (typeof window !== 'undefined' && window !== null) {
  require('./index.styl')
}

export default function $filterContentKeywords (props) {
  const { filter, valueStreams } = props

  return z('.z-filter-content-keywords', [
    z('.label', [
      z('.input', [
        z($input, {
          valueStreams,
          placeholder: filter.placeholder
        })
      ])
    ])
  ])
};
