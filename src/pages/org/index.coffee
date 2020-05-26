{z, useContext, useMemo, useStream} = require 'zorium'
RxObservable = require('rxjs/Observable').Observable
require 'rxjs/add/observable/of'

$appBar = require '../../components/app_bar'
$buttonBack = require '../../components/button_back'
$org = require '../../components/org'
colors = require '../../colors'
context = require '../../context'

if window?
  require './index.styl'

module.exports = $orgPage = ({requestsStream}) ->
  {model} = useContext context

  {irsOrgStream} = useMemo ->
    {
      irsOrgStream: requestsStream.switchMap ({route}) =>
        console.log 'get', route.params.ein
        model.irsOrg.getByEin route.params.ein
    }
  , []

  {irsOrg} = useStream ->
    irsOrg: irsOrgStream

  console.log 'org', irsOrg

  z '.p-org',
    z $appBar, {
      title: irsOrg?.name
      $topLeftButton: z $buttonBack, {
        color: colors.$header500Icon
      }
    }
    z $org, {irsOrgStream}
