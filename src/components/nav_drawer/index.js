// TODO: This file was created by bulk-decaffeinate.
// Sanity-check the conversion and remove this comment.
let $navDrawer;
import {z, classKebab, useContext, useMemo, useStream} from 'zorium';
import * as _ from 'lodash-es';
import * as Rx from 'rxjs';
import * as rx from 'rxjs/operators';

import $button from 'frontend-shared/components/button';
import $drawer from 'frontend-shared/components/drawer';
import $icon from 'frontend-shared/components/icon';
import {
  chevronUpIconPath, chevronDownIconPath
} from 'frontend-shared/components/icon/paths';
import $ripple from 'frontend-shared/components/ripple';
import Environment from 'frontend-shared/services/environment';

import colors from '../../colors';
import context from '../../context';
import config from '../../config';

if (typeof window !== 'undefined' && window !== null) {
  const IScroll = require('iscroll/build/iscroll-lite-snap-zoom.js');
  require('./index.styl');
}

// TODO: if using this with entity/groupStream, get it from context
export default $navDrawer = function({entityStream, currentPath}) {
  const {model, lang, browser, router} = useContext(context);

  var {meStream, isRateLoadingStream, expandedItemsStream, myEntitiesStream,
    menuItemsInfoStream, entityAndMyEntities} = useMemo(function() {

    meStream = model.user.getMe();
    myEntitiesStream = meStream.pipe(rx.switchMap(me => Rx.of([])));
    isRateLoadingStream = new Rx.BehaviorSubject(false);

    return {
      me: meStream,
      isRateLoadingStream,
      expandedItemsStream: new Rx.BehaviorSubject([]),
      myEntitiesStream,
      menuItemsInfoStream: Rx.combineLatest(
        meStream.pipe(rx.startWith(null)),
        entityStream.pipe(rx.startWith(null)),
        lang.getLanguage().pipe(rx.startWith(null)),
        isRateLoadingStream.pipe(rx.startWith(null))
      ),
      entityAndMyEntities: Rx.combineLatest(
        entityStream,
        myEntitiesStream,
        meStream,
        lang.getLanguage(),
        (...vals) => vals)
    };
  }
  , []);

  var {isOpen, language, me, expandedItems, entity, windowSize, drawerWidth,
    breakpoint, menuItems} = useStream(() => ({
    isOpen: model.drawer.isOpen(),
    language: lang.getLanguage(),
    me: meStream,
    expandedItems: expandedItemsStream,
    entity: entityStream,

    // myEntities: entityAndMyEntities.pipe rx.map (props) ->
    //   [entity, entities, me, language] = props
    //   entities = _.orderBy entities, (entity) ->
    //     cookie.get("entity_#{entity.id}_.lastVisit") or 0
    //   , 'desc'
    //   entities = _.filter entities, ({id}) ->
    //     id isnt entity.id
    //   myEntities = _.map entities, (entity, i) ->
    //     {
    //       entity
    //       slug: entity.slug
    //     }
    //   myEntities

    windowSize: browser.getSize(),

    drawerWidth: browser.getDrawerWidth(),
    breakpoint: browser.getBreakpoint(),

    menuItems: menuItemsInfoStream.pipe(rx.map(function(menuItemsInfo) {
      let isRateLoading;
      [me, entity, language, isRateLoading] = Array.from(menuItemsInfo);

      const meEntityUser = entity?.meEntityUser;

      const userAgent = browser.getUserAgent();
      const isNativeApp = Environment.isNativeApp({userAgent});
      const needsApp = userAgent &&
                !isNativeApp &&
                !window?.matchMedia('(display-mode: standalone)').matches;

      const isMember = Boolean(me?.email);
      const hasStripeId = me?.flags?.hasStripeId;

      return _.filter([
        {
          path: router.get('donate'),
          title: lang.get('general.organizations'),
          iconName: '', // TODO icon path
          isDefault: true
        },
        {
          path: router.get('notifications'),
          title: lang.get('general.notifications'),
          iconName: '' // TODO icon path
        }
        // if needsApp or isNativeApp
        //   {
        //     isDivider: true
        //   }
        // if needsApp
        //   {
        //     onclick: ->
        //       portal.call 'app.install', {entity}
        //       model.drawer.close()
        //     title: lang.get 'drawer.menuItemNeedsApp'
        //     iconName: '' # TODO icon path
        //   }
        // else if isNativeApp
        //   {
        //     onclick: ->
        //       ga? 'send', 'event', 'drawer', 'rate'
        //       isRateLoading.next true
        //       # once ios app v2.0.0+ is out, use this
        //       # portal.call 'app.rate'
        //       portal.appRate()
        //       .catch (err) ->
        //         isRateLoading.next false
        //       .then ->
        //         isRateLoading.next false
        //         model.drawer.close()
        //     title: if isRateLoading \
        //            then lang.get 'general.loading' \
        //            else lang.get 'drawer.menuItemRate'
        //     iconName: '' # TODO icon path
        //   }
        ]);
    })
    )
  }));

  // useMemo expandedItems
  const isExpandedByPath = path => expandedItems.indexOf(path) !== -1;

  // useMemo expandedItems
  function toggleExpandItemByPath(path) {
    const isExpanded = isExpandedByPath(path);

    if (isExpanded) {
      expandedItems = _.clone(expandedItems);
      expandedItems.splice(expandedItems.indexOf(path), 1);
      return expandedItemsStream.next(expandedItems);
    } else {
      return expandedItemsStream.next(expandedItems.concat([path]));
    }
  }



  if (entity == null) { entity = {}; }

  console.log('----------------------ENTITY', entity);

  const translateX = isOpen ? 0 : `-${drawerWidth}px`;
  // adblock plus blocks has-ad
  const hasA = false; //model.ad.isVisible({isWebOnly: true}) and
  // windowSize?.height > 880 and
  // not Environment.isMobile()

  function renderChild(child, depth = 0) {
    const {path, title, $chevronIcon, children, expandOnClick} = child;
    const isSelected = currentPath?.indexOf(path) === 0;
    const isExpanded = isSelected || isExpandedByPath(path || title);

    const hasChildren = !_.isEmpty(children);
    return z('li.menu-item',
      z('a.menu-item-link.is-child', {
        className: classKebab({isSelected}),
        href: path,
        onclick(e) {
          e.preventDefault();
          if (expandOnClick) {
            return expand();
          } else {
            model.drawer.close();
            return router.goPath(path);
          }
        }
      },
        z('.icon'),
        title,
        hasChildren ?
          z('.chevron',
            z($chevronIcon, {
              icon: isExpanded 
                    ? chevronUpIconPath 
                    : chevronDownIconPath,
              color: colors.$bgText70,
              isAlignedRight: true,
              onclick: expand
            }
            )
          ) : undefined
      ),
      hasChildren && isExpanded ?
        z(`ul.children-${depth}`,
          _.map(children, child => renderChild(child, depth + 1))
        ) : undefined
    );
  }

  return z('.z-nav-drawer',
    z($drawer, {
      model,
      isOpenStream: model.drawer.isOpen(),
      onOpen: model.drawer.open,
      onClose: model.drawer.close,
      $content:
        z('.z-nav-drawer_drawer', {
          className: classKebab({hasA})
        },
          z('.header',
            z('.icon'),
            z('.name', entity?.name)),
          z('.content',
            z('ul.menu',
              [
                // if me and not me?.email
                //   [
                //     z 'li.sign-in-buttons',
                //       z '.button',
                //         z $button,
                //           isPrimary: true
                //           isFullWidth: true
                //           text: lang.get 'general.signIn'
                //           onclick: ->
                //             model.overlay.open z $signInOverlay, {model, router, data: 'signIn'}
                //       z '.button',
                //         z $button,
                //           isPrimary: true
                //           isFullWidth: true
                //           text: lang.get 'general.signUp'
                //           onclick: ->
                //             model.overlay.open z $signInOverlay, {model, router, data: 'join'}
                //     z 'li.divider'
                //   ]
                _.map(menuItems, function(menuItem) {
                  let isSelected;
                  const {path, onclick, title, $chevronIcon, isNew,
                    iconName, isDivider, children, expandOnClick,
                    color} = menuItem;

                  const hasChildren = !_.isEmpty(children);

                  if (isDivider) {
                    return z('li.divider');
                  }

                  if (menuItem.isDefault) {
                    isSelected = (currentPath === router.get('home')) ||
                      (currentPath && (currentPath.indexOf(path) === 0));
                  } else {
                    isSelected = currentPath?.indexOf(path) === 0;
                  }

                  const isExpanded = isSelected || isExpandedByPath(path || title);

                  function expand(e) {
                    e?.stopPropagation();
                    e?.preventDefault();
                    return toggleExpandItemByPath(path || title);
                  }

                  return z('li.menu-item', {
                    className: classKebab({isSelected})
                  },
                    z('a.menu-item-link', {
                      href: path,
                      style:
                        color ?
                          {color} : undefined,
                      onclick(e) {
                        e.preventDefault();
                        if (expandOnClick) {
                          return expand();
                        } else if (onclick) {
                          return onclick();
                        } else if (path) {
                          router.goPath(path);
                          return model.drawer.close();
                        }
                      }
                    },
                      z('.icon',
                        z($icon, {
                          icon: iconName,
                          size: '26px',
                          color: isSelected 
                                 ? colors.$primaryMainText 
                                 : color || colors.$primaryMainText54
                        }
                        )
                      ),
                      title,
                      z('.notification', {
                        className: classKebab({
                          isVisible: menuItem.hasNotification
                        })
                      }),
                      hasChildren ?
                        z('.chevron',
                          z($chevronIcon, {
                            icon: isExpanded 
                                  ? chevronUpIconPath 
                                  : chevronDownIconPath,
                            color: colors.$bgText70,
                            isAlignedRight: true,
                            touchHeight: '28px',
                            onclick: expand
                          }
                          )
                        ) : undefined,
                      breakpoint === 'desktop' ?
                        z($ripple, {color: colors.$bgText54}) : undefined),
                    hasChildren && isExpanded ?
                      z('ul.children',
                        _.map(children, child => renderChild(child, 1))
                      ) : undefined
                  );
                })

                // unless _.isEmpty myEntities
                //   z 'li.divider'

            ])))
    }));
};
