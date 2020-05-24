{z, useMemo, useStream} = require 'zorium'
RxObservable = require('rxjs/Observable').Observable
require 'rxjs/add/observable/of'

$appBar = require '../../components/app_bar'
$buttonBack = require '../../components/button_back'
$fund = require '../../components/fund'
colors = require '../../colors'

if window?
  require './index.styl'

module.exports = $fundPage = ({model, requestsStream, router}) ->
  {irsFundStream} = useMemo ->
    {
      irsFundStream: requestsStream.switchMap ({route}) =>
        model.irsFund.getByEin route.params.ein
    }
  , []

  {irsFund} = useStream ->
    irsFund: irsFundStream

  # FIXME: canonical to correct/current slug (also do for orgs)
  # /fund/slug/ein

  console.log 'abc'

  z '.p-fund',
    z $appBar, {
      model
      title: irsFund?.name
      $topLeftButton: z $buttonBack, {
        model, router, color: colors.$header500Icon
      }
    }
    z $fund, {model, router, irsFundStream}
