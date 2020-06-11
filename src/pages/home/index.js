let $homePage;
import z from 'zorium';

import $spinner from 'frontend-shared/components/spinner';

import config from '../../config';

if (typeof window !== 'undefined' && window !== null) {
  require('./index.styl');
}

export default $homePage = ({requestsStream, serverData, entity}) => z('.p-home',
  $spinner);
