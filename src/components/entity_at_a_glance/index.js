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

export default function $entityAtAGlance (props) {
  const { placeholderNameStream, entity, entityType } = props
  const { lang, router } = useContext(context)

  const { placeholderName } = useStream(() => ({
    placeholderName: placeholderNameStream
  }))

  return z('.z-entity-at-a-glance', [
    z('.name', entity?.name || placeholderName),

    z('.block', [
      z('.title', lang.get('general.location')),
      z('.text', FormatService.location(entity))
    ]),

    entity?.website && entity.website !== 'N/A' &&
      z('.block', [
        z('.title', lang.get('general.web')),
        router.link(z('a.text.link', {
          href: entity?.website
        }, entity?.website))
      ]),

    entity?.mission &&
      z('.block', [
        z('.title', lang.get('general.mission')),
        entity?.mission
      ]),

    entityType === 'irsOrg' &&
      [
        z('.divider'),
        z('.grant-summary', [
          z('.metric', [
            z('.name', lang.get('org.assets')),
            z('.value',
              FormatService.abbreviateDollar(entity?.assets)
            )
          ]),
          z('.metric', [
            z('.name', lang.get('org.employees')),
            z('.value',
              FormatService.abbreviateNumber(entity?.employeeCount)
            )
          ]),
          z('.metric', [
            z('.name', lang.get('org.volunteers')),
            z('.value',
              FormatService.abbreviateNumber(entity?.volunteerCount)
            )
          ])
        ])
      ],
    entityType === 'irsFund' && entity?.lastYearStats &&
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
              FormatService.abbreviateDollar(entity?.lastYearStats?.grantMedian)
            )
          ]),
          z('.metric', [
            z('.name', lang.get('filter.grantCount')),
            z('.value',
              FormatService.abbreviateNumber(entity?.lastYearStats?.grants)
            )
          ]),
          z('.metric', [
            z('.name', lang.get('filter.grantSum')),
            z('.value',
              FormatService.abbreviateDollar(entity?.lastYearStats?.grantSum)
            )
          ]),
          z('.metric', [
            z('.name', lang.get('org.assets')),
            z('.value',
              FormatService.abbreviateDollar(entity?.assets)
            )
          ])
        ])
      ]
  ])
};
