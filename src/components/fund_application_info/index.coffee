{z} = require 'zorium'

$icon = require '../icon'

if window?
  require './index.styl'

module.exports = $fundApplicationInfo = ({model, router, irsFund}) ->
  console.log irsFund
  z '.z-fund-application-info',
    if irsFund?.applicantInfo
      [
        unless irsFund.applicantInfo.acceptsUnsolicitedRequests
          z '.warning',
            z '.icon',
              z $icon,
                icon: 'info'
                isTouchTarget: false
            z '.text', model.l.get 'fundApplicantInfo.noUnsolicited'
        z '.title', model.l.get 'fundApplicantInfo.deadline'
        z '.block', irsFund.applicantInfo.deadlines

        z '.title', model.l.get 'fundApplicantInfo.instructions'
        z '.block', irsFund.applicantInfo.requirements

        z '.title', model.l.get 'fundApplicantInfo.restrictions'
        z '.block', irsFund.applicantInfo.restrictions

        z '.title', model.l.get 'general.contact'
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
