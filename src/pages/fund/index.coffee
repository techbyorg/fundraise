{z, useMemo, useStream} = require 'zorium'
RxObservable = require('rxjs/Observable').Observable
require 'rxjs/add/observable/of'

$appBar = require '../../components/app_bar'
$buttonBack = require '../../components/button_back'
# $fund = require '../../components/fund'
colors = require '../../colors'

if window?
  require './index.styl'

module.exports = FundPage = ({model, requests, router}) ->
  {irsFundStream} = useMemo ->
    {
      irsFundStream: requests.switchMap ({route}) =>
        console.log 'get', route.params.ein
        model.irsFund.getByEin route.params.ein
    }
  , []

  {irsFund} = useStream ->
    irsFund: irsFundStream

  console.log 'fund', irsFund

  z '.p-fund',
    z $appBar, {
      model
      title: irsFund?.data?.irsFund.name
      $topLeftButton: z $buttonBack, {
        model, router, color: colors.$header500Icon
      }
    }
    # z $fund, {model, router, irsFundStream}
