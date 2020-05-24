{z} = require 'zorium'

$policies = require '../../components/policies'

if window?
  require './index.styl'

module.exports = $policiesPage = ({model, requestsStream, router}) ->
  z '.p-policies',
    z $policies, {
      model, router
      isIabStream: requestsStream.map ({req}) ->
        req.query.isIab
    }
