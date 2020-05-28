{z, useContext, useMemo, useStream} = require 'zorium'
RxObservable = require('rxjs/Observable').Observable
require 'rxjs/add/observable/of'

import $appBar from 'frontend-shared/components/app_bar'
import $buttonBack from 'frontend-shared/components/button_back'

import $org from '../../components/org'
import colors from '../../colors'
import context from '../../context'

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
