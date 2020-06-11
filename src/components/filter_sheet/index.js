// TODO: This file was created by bulk-decaffeinate.
// Sanity-check the conversion and remove this comment.
let $filterSheet;
import {z, useContext, useMemo, useStream} from 'zorium';
import * as Rx from 'rxjs';
import * as rx from 'rxjs/operators';

import $sheet from 'frontend-shared/components/sheet';
import $button from 'frontend-shared/components/button';

import $filterContent from '../filter_content';
import colors from '../../colors';
import context from '../../context';
import config from '../../config';

if (typeof window !== 'undefined' && window !== null) {
  require('./index.styl');
}

export default $filterSheet = function({id, filter, onClose}) {
  const {lang} = useContext(context);

  var {valueStreams} = useMemo(function() {
    valueStreams = new Rx.ReplaySubject(1);
    valueStreams.next(filter.valueStreams.pipe(rx.switchAll()));
    return {
      valueStreams
    };
  }
  , []);

  const {filterValue, hasValue} = useStream(() => ({
    filterValue: filter.valueStreams.pipe(rx.switchAll()),

    hasValue: valueStreams.pipe(
      rx.switchAll(),
      rx.map(value => Boolean(value)),
      rx.distinctUntilChanged((a, b) => a === b) // don't rerender a bunch
    )
  }));

  return z('.z-filter-sheet',
    {key: filter.id},
    z($sheet, {
      id: filter.id,
      onClose,
      $content:
        z('.z-filter-sheet_sheet',
          z('.actions',
            z('.reset',
              hasValue ?
                z($button, {
                  text: lang.get('general.reset'),
                  onclick() {
                    filter.valueStreams.next(Rx.of(null));
                    return valueStreams.next(Rx.of(null));
                  }
                }
                ) : undefined
            ),
            z('.save',
              z($button, {
                text: lang.get('general.save'),
                isPrimary: true,
                onclick() {
                  filter.valueStreams.next(valueStreams.pipe(rx.switchAll()));
                  return onClose();
                }
              }
              )
            )
          ),
          z('.title',
            filter?.title || filter?.name),
          z($filterContent, {
            filter, filterValue, valueStreams, overlayAnchor: 'bottom-left'
          }))
    }));
};
