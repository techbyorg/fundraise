{z} = require 'zorium'

$policies = require '../../components/policies'

if window?
  require './index.styl'

module.exports = $policiesPage = ({model, requests, router}) ->
  z '.p-policies',
    z $policies, {
      model, router
      isIabStream: requests.map ({req}) ->
        req.query.isIab
    }
