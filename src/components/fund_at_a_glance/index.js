import { z, useContext, useStream } from 'zorium'

// import $tags from 'frontend-shared/components/tags'
import $icon from 'frontend-shared/components/icon'
import { giveIconPath } from 'frontend-shared/components/icon/paths'
import FormatService from 'frontend-shared/services/format'

import colors from '../../colors'
import context from '../../context'

if (typeof window !== 'undefined' && window !== null) {
  require('./index.styl')
}

export default function $fundAtAGlance ({ placeholderNameStream, irsFund }) {
  const { lang, router } = useContext(context)

  const { placeholderName } = useStream(() => ({
    placeholderName: placeholderNameStream
  }))

  return z('.z-fund-at-a-glance', [
    z('.name', irsFund?.name || placeholderName),

    z('.block', [
      z('.title', lang.get('general.location')),
      z('.text', FormatService.location(irsFund))
    ]),

    irsFund?.website &&
      z('.block', [
        z('.title', lang.get('general.web')),
        router.link(z('a.text.link', {
          href: irsFund?.website
        }, irsFund?.website))
      ]),

    irsFund?.lastYearStats &&
      [
        z('.divider'),
        z('.grant-summary', [
          z('.title', [
            z('.icon', [
              z($icon, {
                icon: giveIconPath,
                color: colors.$secondaryMain
              })
            ]),
            lang.get('fund.grantSummary')
          ]),
          z('.metric', [
            z('.name', lang.get('fund.medianGrant')),
            z('.value',
              FormatService.abbreviateDollar(irsFund?.lastYearStats?.grantMedian)
            )
          ]),
          z('.metric', [
            z('.name', lang.get('filter.grantCount')),
            z('.value',
              FormatService.abbreviateNumber(irsFund?.lastYearStats?.grants)
            )
          ]),
          z('.metric', [
            z('.name', lang.get('filter.grantSum')),
            z('.value',
              FormatService.abbreviateDollar(irsFund?.lastYearStats?.grantSum)
            )
          ]),
          z('.metric', [
            z('.name', lang.get('org.assets')),
            z('.value',
              FormatService.abbreviateDollar(irsFund?.assets)
            )
          ])
        ])
      ]
  ])
};
