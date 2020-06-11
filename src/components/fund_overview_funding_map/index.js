let $fundOverviewNteePie;
import {z} from 'zorium';
import * as _ from 'lodash-es';

import $chartUsMap from '../chart_us_map';
import config from '../../config';

if (typeof window !== 'undefined' && window !== null) {
  require('./index.styl');
}

export default $fundOverviewNteePie = function({irsFund}) {
  const data = _.map(irsFund?.fundedStates, ({key, sum}) => ({
    id: key,
    value: sum
  }));

  return z('.z-fund-overview-funding-map',
    z($chartUsMap, {data}));
};
