import {z, useContext, useMemo, useStream} from 'zorium'
RxObservable = require('rxjs/Observable').Observable
require 'rxjs/add/observable/of'
import _startCase from 'lodash/startCase'

import $appBar from 'frontend-shared/components/app_bar'
import $buttonBack from 'frontend-shared/components/button_back'

import $fund from '../../components/fund'
import colors from '../../colors'
import context from '../../context'

if window?
  require './index.styl'

export default $fundPage = ({requestsStream}) ->
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
