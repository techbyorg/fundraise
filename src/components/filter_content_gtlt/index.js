let $filterContentGtlt;
import {z, classKebab, useEffect, useMemo} from 'zorium';
import * as Rx from 'rxjs';
import * as rx from 'rxjs/operators';

import $icon from 'frontend-shared/components/icon';
import $inputOld from 'frontend-shared/components/input_old';
import {
  chevronRightIconPath, chevronLeftIconPath
} from 'frontend-shared/components/icon/paths';

import colors from '../../colors';

if (typeof window !== 'undefined' && window !== null) {
  require('./index.styl');
}

export default $filterContentGtlt = function() {
  const {filterValueStr, resetValue, valueStreams, filterValue} = props;

  var {operatorStream, valueStream} = useMemo(function() {
    operatorStream = new Rx.BehaviorSubject(filterValue?.operator);
    valueStream = new Rx.BehaviorSubject(filterValue?.value || '');
    valueStreams.next(Rx.combineLatest(
      operatorStream, valueStream, (...vals) => vals).pipe(rx.map(function(...args) {
      let value;
      let operator;
      [operator, value] = Array.from(args[0]);
      if (operator || value) {
        return {operator, value};
      }})));

    return {operatorStream, valueStream};
  }
  , []);

  useEffect(function() {
    operatorStream.next(filterValue?.operator);
    return valueStream.next(filterValue?.value || '');
  }
  , [filterValueStr, resetValue]); // need to recreate valueStreams when resetting

  const operator = filterValue?.operator;

  return z('.z-filter-content-gtlt',
    z('.label',
      z('.text', 'gtlt'), // FIXME
      z('.operators',
        z('.operator', {
          className: classKebab({
            isSelected: operator === 'gt'
          }),
          onclick: () => {
            return operatorStream.next('gt');
          }
        },
          z($icon, {
            icon: chevronRightIconPath,
            size: '20px',
            color: operator === 'gt' 
                    ? colors.$secondaryMainText 
                    : colors.$bgText38
          }
          )
        ),
        z('.operator', {
          className: classKebab({
            isSelected: operator === 'lt'
          }),
          onclick: () => {
            return operatorStream.next('lt');
          }
        },
          z($icon, {
            icon: chevronLeftIconPath,
            size: '20px',
            color: operator === 'lt' 
                    ? colors.$secondaryMainText 
                    : colors.$bgText38
          }
          )
        )
      ),
      z('.operator-input-wide',
        z($inputOld, {
          valueStream,
          type: 'number',
          height: '24px'
        }))));
};

