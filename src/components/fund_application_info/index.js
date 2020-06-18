import { z, useContext } from 'zorium'

import $icon from 'frontend-shared/components/icon'
import { infoIconPath } from 'frontend-shared/components/icon/paths'

import context from '../../context'

if (typeof window !== 'undefined' && window !== null) {
  require('./index.styl')
}

export default function $fundApplicationInfo ({ entity }) {
  const { lang } = useContext(context)

  return z('.z-fund-application-info', [
    entity?.applicantInfo &&
      [
        !entity.applicantInfo.acceptsUnsolicitedRequests &&
          z('.warning', [
            z('.icon', z($icon, { icon: infoIconPath })),
            z('.text', lang.get('fundApplicantInfo.noUnsolicited'))
          ]),
        z('.title', lang.get('fundApplicantInfo.deadline')),
        z('.block', entity.applicantInfo.deadlines),

        z('.title', lang.get('fundApplicantInfo.instructions')),
        z('.block', entity.applicantInfo.requirements),

        z('.title', lang.get('fundApplicantInfo.restrictions')),
        z('.block', entity.applicantInfo.restrictions),

        z('.title', lang.get('general.contact')),
        z('.name', entity.applicantInfo.recipientName),
        entity.applicantInfo.address &&
          [
            z('.address-line', entity.applicantInfo.address.street1),
            entity.applicantInfo.address.street2 &&
              z('.address-line', entity.applicantInfo.address.street2),
            z('.address-line', [
              `${entity.applicantInfo.address.city}, `,
              entity.applicantInfo.address.state,
              ` ${entity.applicantInfo.address.postalCode}`
            ])
          ]
      ]
  ])
};
