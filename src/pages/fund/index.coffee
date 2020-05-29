import {z, useContext, useMemo, useStream} from 'zorium'
import * as _ from 'lodash-es'
import * as rx from 'rxjs/operators'

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
      placeholderNameStream: requestsStream.pipe rx.map ({route}) =>
        _.startCase route.params.slug
      irsFundStream: requestsStream.pipe rx.switchMap ({route}) =>
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
