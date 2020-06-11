let $fundPage;
import {z, useContext, useMemo, useStream} from 'zorium';
import * as _ from 'lodash-es';
import * as rx from 'rxjs/operators';

import $appBar from 'frontend-shared/components/app_bar';
import $buttonBack from 'frontend-shared/components/button_back';
import useMeta from 'frontend-shared/services/use_meta';

import $fund from '../../components/fund';
import colors from '../../colors';
import context from '../../context';

if (typeof window !== 'undefined' && window !== null) {
  require('./index.styl');
}

export default $fundPage = function({requestsStream}) {
  const {model} = useContext(context);

  const {placeholderNameStream, irsFundStream, tabStream} = useMemo(() => ({
    // for smoother loading
    placeholderNameStream: requestsStream.pipe(rx.map(({route}) => _.startCase(route.params.slug))
    ),

    irsFundStream: requestsStream.pipe(rx.switchMap(({route}) => model.irsFund.getByEin(route.params.ein))
    ),

    tabStream: requestsStream.pipe(rx.map(({route}) => route.params.tab)
    )
  })
  , []);

  const {irsFund} = useStream(() => ({
    irsFund: irsFundStream
  }));

  useMeta(function() {
    if (irsFund) {
      return {title: irsFund?.name};
    }
  }
  , [irsFund?.name]);

  return z('.p-fund',
    z($appBar, {
      // title: irsFund?.name
      hasLogo: true,
      isRaised: true,
      isContained: false,
      $topLeftButton: z($buttonBack, {
        color: colors.$header500Icon
      })
    }),
    z($fund, {placeholderNameStream, irsFundStream, tabStream}));
};
