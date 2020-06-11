let $filterContentNtee;
import {z, Boundary, Fragment, Suspense, classKebab, lazy, useContext, useEffect, useMemo, useStream} from 'zorium';
import * as _ from 'lodash-es';
import * as Rx from 'rxjs';
import * as rx from 'rxjs/operators';

import $checkbox from 'frontend-shared/components/checkbox';
import $input from 'frontend-shared/components/input';
import $icon from 'frontend-shared/components/icon';
import {
  searchIconPath, chevronDownIconPath, chevronUpIconPath
} from 'frontend-shared/components/icon/paths';
import $spinner from 'frontend-shared/components/spinner';

import context from '../../context';

if (typeof window !== 'undefined' && window !== null) {
  require('./index.styl');
}

const SEARCH_DEBOUNCE_MS = 300;

const getNtees = () => import(/* webpackChunkName: "ntee" */'./ntee.coffee')
.then(module => module.default);

const searchLabel = (label, search) => label.toLowerCase().indexOf(search.toLowerCase()) !== -1;

const _$filterContentNtee = lazy(() => getNtees().then(ntees => (function(props) {
  let groupsStream, groupTogglesStream, nteeValueStreams, searchStream;
  const {filterValueStr, resetValue, filter, valueStreams, filterValue} = props;
  const {lang} = useContext(context);

  ({nteeValueStreams, groupTogglesStream, searchStream,
    groupsStream, searchStream} = useMemo(function() {
    searchStream = new Rx.BehaviorSubject('');
    groupTogglesStream = new Rx.BehaviorSubject({});

    const searchAndGroupTogglesStream = Rx.combineLatest(
      searchStream.pipe(
        rx.filter(search => search?.length > 2),
        rx.startWith(''),
        rx.debounceTime(SEARCH_DEBOUNCE_MS)
      ),
      groupTogglesStream, (...vals) => vals);

    nteeValueStreams = _.reduce(ntees, function(obj, {label, children}, key) {
      obj[key] = new Rx.BehaviorSubject(filterValue?.nteeMajors[key]);
      _.forEach(children, (label, key) => obj[key] = new Rx.BehaviorSubject(filterValue?.ntees[key]));
      return obj;
    }
    , {});

    groupsStream = searchAndGroupTogglesStream.pipe(rx.map(function(...args) {
      let search, groupToggles;
      [search, groupToggles] = Array.from(args[0]);
      return _.mapValues(ntees, ({label, children}, key) => {
        const hasMatch = searchLabel(label, search);
        children = _.map(children, function(label, key) {
          const isValueSet = nteeValueStreams[key].getValue();
          return {
            key,
            label,
            valueStream: nteeValueStreams[key],
            isVisible: isValueSet || (search && searchLabel(label, search))
          };
      });
        const hasChildrenMatches = _.find(children, {isVisible: true});
        const isOpen = (hasChildrenMatches && (groupToggles[key] !== false)) ||
                  groupToggles[key];
        return {
          key, label, isOpen, hasMatch, children,
          isVisible: hasMatch || hasChildrenMatches,
          valueStream: nteeValueStreams[key]
        };
    });}));

    valueStreams.next(Rx.combineLatest(
      _.values(nteeValueStreams), (...vals) => vals).pipe(rx.map(function(vals) {
      if (!_.isEmpty(_.filter(vals))) {
        const keys = _.keys(nteeValueStreams);
        return _.reduce(vals, function(obj, val, i) {
          const key = keys[i];
          if (val && (key.length === 1)) {
            obj.nteeMajors[key] = val;
          } else if (val) {
            obj.ntees[key] = val;
          }
          return obj;
        }
        , {nteeMajors: {}, ntees: {}});
      }})));

    return {
      nteeValueStreams,
      groupTogglesStream,
      searchStream,
      groupsStream,
      searchStream
    };
  }
  , []));

  useEffect(function() {
    console.log('eff', filterValue);
    return _.forEach(ntees, function({label, children}, key) {
      nteeValueStreams[key].next(filterValue?.nteeMajors[key]);
      return _.forEach(children, (label, key) => nteeValueStreams[key].next(filterValue?.ntees[key]));
    }
    , {});
  }
  , [filterValueStr, resetValue]);

  const {groupToggles, search, groups} = useStream(() => ({
    groupToggles: groupTogglesStream,
    search: searchStream,
    groups: groupsStream
  }));

  return z(Fragment,
    z('.search',
      z($input, {
        icon: searchIconPath,
        placeholder: lang.get('filterContentNtee.searchPlaceholder'),
        valueStream: searchStream
      })),
    _.map(groups, function(group) {
      const {key, valueStream, label, children, isOpen, isVisible} = group;
      return z('.group', {
        className: classKebab({isVisible})
      },
        z('label.label',
          z('.checkbox',
            z($checkbox, {
              valueStream,
              onChange(val) {
                if (val) {
                  return groupTogglesStream.next(
                    _.defaults({[key]: false}, groupToggles)
                  );
                }
              }
            })),
          z('.text', label || 'fixme'),
          !search ?
            z('.open', {
              onclick(e) {
                e.preventDefault();
                if (isOpen) {
                  return groupTogglesStream.next(
                    _.defaults({[key]: false}, groupToggles)
                  );
                } else {
                  return groupTogglesStream.next(
                    _.defaults({[key]: true}, groupToggles)
                  );
                }
              }
            },
              z($icon, {
                icon: isOpen 
                      ? chevronUpIconPath 
                      : chevronDownIconPath
              }
              )
            ) : undefined
        ),

        isOpen ? // having these always in dom is slow on first load
          z('.children',
          _.map(children, function({key, isVisible, valueStream, label}) {
            // if group is open and no search, show all
            if (!isVisible) { isVisible = !search; }
            return z('label.label', {
              key,
              className: classKebab({isVisible})
            },
              z('.checkbox',
                z($checkbox, {
                  valueStream,
                  onChange(val) {
                    if (val) {
                      // disable parent
                      return nteeValueStreams[key.substr(0, 1)].next(false);
                    }
                  }
                })),
              z('.text', label || 'fixme'));
          })
          ) : undefined
      );
    })
  );
})));



export default $filterContentNtee = props => z('.z-filter-content-ntee',
  z(Boundary, {fallback: z('.error', 'err')},
    z(Suspense, {fallback: z($spinner)},
      z(_$filterContentNtee, props))
  )
);
