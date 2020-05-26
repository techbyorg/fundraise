{z, useContext, useMemo, useStream} = require 'zorium'
RxObservable = require('rxjs/Observable').Observable
require 'rxjs/add/observable/of'
_startCase = require 'lodash/startCase'

$appBar = require '../../components/app_bar'
$buttonBack = require '../../components/button_back'
$fund = require '../../components/fund'
colors = require '../../colors'
context = require '../../context'

if window?
  require './index.styl'

module.exports = $fundPage = ({requestsStream}) ->
  {model} = useContext context

  {placeholderNameStream, irsFundStream} = useMemo ->
    {
      # for smoother loading
      placeholderNameStream: requestsStream.map ({route}) =>
        _startCase route.params.slug
      irsFundStream: requestsStream.switchMap ({route}) =>
        model.irsFund.getByEin route.params.ein
    }
  , []

  {irsFund} = useStream ->
    irsFund: irsFundStream

  z '.p-fund',
    z $appBar, {
      # title: irsFund?.name
      $topLeftButton: z $buttonBack, {
        color: colors.$header500Icon
      }
    }
    z $fund, {placeholderNameStream, irsFundStream}
