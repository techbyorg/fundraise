// TODO: This file was created by bulk-decaffeinate.
// Sanity-check the conversion and remove this comment.
let $orgPage;
import {z, useContext, useMemo, useStream} from 'zorium';
import * as rx from 'rxjs/operators';

import $appBar from 'frontend-shared/components/app_bar';
import $buttonBack from 'frontend-shared/components/button_back';

import $org from '../../components/org';
import colors from '../../colors';
import context from '../../context';

if (typeof window !== 'undefined' && window !== null) {
  require('./index.styl');
}

export default $orgPage = function({requestsStream}) {
  const {model} = useContext(context);

  const {irsOrgStream} = useMemo(() => ({
    irsOrgStream: requestsStream.pipe(rx.switchMap(({route}) => {
      console.log('get', route.params.ein);
      return model.irsOrg.getByEin(route.params.ein);
    })
    )
  })
  , []);

  const {irsOrg} = useStream(() => ({
    irsOrg: irsOrgStream
  }));

  console.log('org', irsOrg);

  return z('.p-org',
    z($appBar, {
      title: irsOrg?.name,
      $topLeftButton: z($buttonBack, {
        color: colors.$header500Icon
      })
    }),
    z($org, {irsOrgStream}));
};
