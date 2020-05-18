{z, useMemo, useStream} = require 'zorium'
RxObservable = require('rxjs/Observable').Observable
require 'rxjs/add/observable/of'

$appBar = require '../../components/app_bar'
$buttonBack = require '../../components/button_back'
$org = require '../../components/org'
colors = require '../../colors'

if window?
  require './index.styl'

module.exports = OrgPage = ({model, requests, router}) ->
  {irsOrgStream} = useMemo ->
    {
      irsOrgStream: requests.switchMap ({route}) =>
        console.log 'get', route.params.ein
        model.irsOrg.getByEin route.params.ein
    }
  , []

  {irsOrg} = useStream ->
    irsOrg: irsOrgStream

  console.log 'org', irsOrg

  z '.p-org',
    z $appBar, {
      model
      title: irsOrg?.name
      $topLeftButton: z $buttonBack, {
        model, router, color: colors.$header500Icon
      }
    }
    z $org, {model, router, irsOrgStream}
