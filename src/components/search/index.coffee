{z} = require 'zorium'

$irsSearch = require '../irs_search'

if window?
  require './index.styl'

module.exports = OrgBox = ({model, router, org}) ->
  z '.z-search',
    z '.title', 'Search foundations'
    z '.input',
      z $irsSearch, {
        model, router, irsType: 'irsFund', hintText: 'Foundation name'
      }
    z '.title', 'Search organizations'
    z '.input',
      z $irsSearch, {
        model, router, irsType: 'irsOrg', hintText: 'Organization name'
      }
    z '.title', 'Search people'
    z '.input',
      z $irsSearch, {
        model, router, irsType: 'irsPerson', hintText: 'Person name'
      }
