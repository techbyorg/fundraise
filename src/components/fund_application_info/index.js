import { z, useContext } from 'zorium'

import $icon from 'frontend-shared/components/icon'
import { infoIconPath } from 'frontend-shared/components/icon/paths'

import context from '../../context'

if (typeof window !== 'undefined' && window !== null) {
  require('./index.styl')
}

export default function $fundApplicationInfo ({ irsFund }) {
  const { lang } = useContext(context)

  return z('.z-fund-application-info', [
    irsFund?.applicantInfo &&
      [
        !irsFund.applicantInfo.acceptsUnsolicitedRequests &&
          z('.warning', [
            z('.icon', z($icon, { icon: infoIconPath })),
            z('.text', lang.get('fundApplicantInfo.noUnsolicited'))
          ]),
        z('.title', lang.get('fundApplicantInfo.deadline')),
        z('.block', irsFund.applicantInfo.deadlines),

        z('.title', lang.get('fundApplicantInfo.instructions')),
        z('.block', irsFund.applicantInfo.requirements),

        z('.title', lang.get('fundApplicantInfo.restrictions')),
        z('.block', irsFund.applicantInfo.restrictions),

        z('.title', lang.get('general.contact')),
        z('.name', irsFund.applicantInfo.recipientName),
        irsFund.applicantInfo.address &&
          [
            z('.address-line', irsFund.applicantInfo.address.street1),
            irsFund.applicantInfo.address.street2 &&
              z('.address-line', irsFund.applicantInfo.address.street2),
            z('.address-line', [
              `${irsFund.applicantInfo.address.city}, `,
              irsFund.applicantInfo.address.state,
              ` ${irsFund.applicantInfo.address.postalCode}`
            ])
          ]
      ]
  ])
};
