// TODO: This file was created by bulk-decaffeinate.
// Sanity-check the conversion and remove this comment.
let $filterContentMinMax;
import {z, classKebab, useEffect, useMemo} from 'zorium';
import * as Rx from 'rxjs';
import * as rx from 'rxjs/operators';

import $dropdown from 'frontend-shared/components/dropdown';

import colors from '../../colors';

if (typeof window !== 'undefined' && window !== null) {
  require('./index.styl');
}

export default $filterContentMinMax = function(props) {
  const {filterValueStr, resetValue, filter, valueStreams, filterValue,
    overlayAnchor, $$parentRef} = props;

  var {minStream, maxStream} = useMemo(function() {
    minStream = new Rx.BehaviorSubject(filterValue?.min || filter.minOptions[0].value);
    maxStream = new Rx.BehaviorSubject(filterValue?.max || filter.maxOptions[0].value);
    valueStreams.next(Rx.combineLatest(
      minStream, maxStream, (...vals) => vals).pipe(rx.map(function(...args) {
      let [min, max] = Array.from(args[0]);
      min = min && parseInt(min);
      max = max && parseInt(max);
      if (min || max) {
        return {min, max};
      }})));

    return {minStream, maxStream};
  }
  , []);

  useEffect(function() {
    minStream.next(filterValue?.min || filter.minOptions[0].value);
    return maxStream.next(filterValue?.max || filter.maxOptions[0].value);
  }
  , [filterValueStr, resetValue]); // need to recreate valueStreams when resetting

  return z('.z-filter-content-min-max',
    z('.flex',
      z('.block',
        z($dropdown, {
          $$parentRef,
          valueStream: minStream,
          options: filter.minOptions,
          anchor: overlayAnchor
        })),
      z('.dash', '-'),
      z('.block',
        z($dropdown, {
          $$parentRef,
          valueStream: maxStream,
          options: filter.maxOptions,
          anchor: overlayAnchor
        }))));
};

