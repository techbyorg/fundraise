{z, useContext} = require 'zorium'

$icon = require '../icon'
context = require '../../context'

if window?
  require './index.styl'

module.exports = $fundApplicationInfo = ({irsFund}) ->
  {lang} = useContext context

  z '.z-fund-application-info',
    if irsFund?.applicantInfo
      [
        unless irsFund.applicantInfo.acceptsUnsolicitedRequests
          z '.warning',
            z '.icon',
              z $icon,
                icon: 'info'
                isTouchTarget: false
            z '.text', lang.get 'fundApplicantInfo.noUnsolicited'
        z '.title', lang.get 'fundApplicantInfo.deadline'
        z '.block', irsFund.applicantInfo.deadlines

        z '.title', lang.get 'fundApplicantInfo.instructions'
        z '.block', irsFund.applicantInfo.requirements

        z '.title', lang.get 'fundApplicantInfo.restrictions'
        z '.block', irsFund.applicantInfo.restrictions

        z '.title', lang.get 'general.contact'
        z '.name', irsFund.applicantInfo.recipientName
        if irsFund.applicantInfo.address
          [
            z '.address-line', irsFund.applicantInfo.address.street1
            if irsFund.applicantInfo.address.street2
              z '.address-line', irsFund.applicantInfo.address.street2
            z '.address-line',
              "#{irsFund.applicantInfo.address.city}, "
              irsFund.applicantInfo.address.state
              " #{irsFund.applicantInfo.address.postalCode}"
          ]
      ]
