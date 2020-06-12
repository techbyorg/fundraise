import { z, classKebab, useContext, useMemo, useStream } from 'zorium'
import * as _ from 'lodash-es'
import * as Rx from 'rxjs'
import * as rx from 'rxjs/operators'

import $drawer from 'frontend-shared/components/drawer'
import $icon from 'frontend-shared/components/icon'
import {
  chevronUpIconPath, chevronDownIconPath
} from 'frontend-shared/components/icon/paths'
import $ripple from 'frontend-shared/components/ripple'

import colors from '../../colors'
import context from '../../context'

if (typeof window !== 'undefined') { require('./index.styl') }

// TODO: if using this with entity/groupStream, get it from context
export default function $navDrawer ({ entityStream, currentPath }) {
  const { model, lang, browser, router } = useContext(context)

  const {
    expandedItemsStream, menuItemsInfoStream
  } = useMemo(function () {
    const meStream = model.user.getMe()
    const myEntitiesStream = meStream.pipe(rx.switchMap(me => Rx.of([])))
    // const isRateLoadingStream = new Rx.BehaviorSubject(false)

    return {
      me: meStream,
      // isRateLoadingStream,
      expandedItemsStream: new Rx.BehaviorSubject([]),
      myEntitiesStream,
      menuItemsInfoStream: Rx.combineLatest(
        meStream.pipe(rx.startWith(null)),
        entityStream.pipe(rx.startWith(null)),
        lang.getLanguage().pipe(rx.startWith(null))
      )
    }
  }
  , [])

  const {
    expandedItems, entity, breakpoint, menuItems
  } = useStream(() => ({
    expandedItems: expandedItemsStream,
    entity: entityStream,
    windowSize: browser.getSize(),
    breakpoint: browser.getBreakpoint(),
    menuItems: menuItemsInfoStream.pipe(rx.map(() => {
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
      ])
    })
    )
  }))

  // useMemo expandedItems
  const isExpandedByPath = path => expandedItems.indexOf(path) !== -1

  // useMemo expandedItems
  function toggleExpandItemByPath (path) {
    const isExpanded = isExpandedByPath(path)

    if (isExpanded) {
      expandedItems.splice(expandedItems.indexOf(path), 1)
      return expandedItemsStream.next(expandedItems)
    } else {
      return expandedItemsStream.next(expandedItems.concat([path]))
    }
  }

  console.log('----------------------ENTITY', entity)

  // const translateX = isOpen ? 0 : `-${drawerWidth}px`
  // adblock plus blocks has-ad
  const hasA = false // model.ad.isVisible({isWebOnly: true}) and
  // windowSize?.height > 880 and
  // not Environment.isMobile()

  function renderChild (child, depth = 0, expand) {
    const { path, title, $chevronIcon, children, expandOnClick } = child
    const isSelected = currentPath?.indexOf(path) === 0
    const isExpanded = isSelected || isExpandedByPath(path || title)

    const hasChildren = !_.isEmpty(children)
    return z('li.menu-item', [
      z('a.menu-item-link.is-child', {
        className: classKebab({ isSelected }),
        href: path,
        onclick (e) {
          e.preventDefault()
          if (expandOnClick) {
            return expand()
          } else {
            model.drawer.close()
            return router.goPath(path)
          }
        }
      }, [
        z('.icon'),
        title,
        hasChildren &&
          z('.chevron', [
            z($chevronIcon, {
              icon: isExpanded
                ? chevronUpIconPath
                : chevronDownIconPath,
              color: colors.$bgText70,
              isAlignedRight: true,
              onclick: expand
            })
          ])
      ]),
      hasChildren && isExpanded &&
        z(`ul.children-${depth}`,
          _.map(children, child => renderChild(child, depth + 1, expand))
        )
    ])
  }

  return z('.z-nav-drawer', [
    z($drawer, {
      model,
      isOpenStream: model.drawer.isOpen(),
      onOpen: model.drawer.open,
      onClose: model.drawer.close,
      $content:
        z('.z-nav-drawer_drawer', {
          className: classKebab({ hasA })
        }, [
          z('.header', [
            z('.icon'),
            z('.name', entity?.name)
          ]),
          z('.content', [
            z('ul.menu',
              _.map(menuItems, (menuItem) => {
                let isSelected
                const {
                  path, onclick, title, $chevronIcon,
                  iconName, isDivider, children, expandOnClick,
                  color
                } = menuItem

                const hasChildren = !_.isEmpty(children)

                if (isDivider) {
                  return z('li.divider')
                }

                if (menuItem.isDefault) {
                  isSelected = (currentPath === router.get('home')) ||
                      (currentPath && (currentPath.indexOf(path) === 0))
                } else {
                  isSelected = currentPath?.indexOf(path) === 0
                }

                const isExpanded = isSelected || isExpandedByPath(path || title)

                const expand = (e) => {
                    e?.stopPropagation()
                    e?.preventDefault()
                    return toggleExpandItemByPath(path || title)
                }

                return z('li.menu-item', {
                  className: classKebab({ isSelected })
                }, [
                  z('a.menu-item-link', {
                    href: path,
                    style: color ? { color } : undefined,
                    onclick: (e) => {
                      e.preventDefault()
                      if (expandOnClick) {
                        expand()
                      } else if (onclick) {
                        onclick()
                      } else if (path) {
                        router.goPath(path)
                        model.drawer.close()
                      }
                    }
                  }, [
                    z('.icon', [
                      z($icon, {
                        icon: iconName,
                        size: '26px',
                        color: isSelected
                          ? colors.$primaryMainText
                          : color || colors.$primaryMainText54
                      })
                    ]),
                    title,
                    z('.notification', {
                      className: classKebab({
                        isVisible: menuItem.hasNotification
                      })
                    }),
                    hasChildren &&
                      z('.chevron', [
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
                      ]),
                    breakpoint === 'desktop' &&
                      z($ripple, { color: colors.$bgText54 }),
                    hasChildren && isExpanded &&
                      z('ul.children',
                        _.map(children, child => renderChild(child, 1, expand))
                      )
                  ])
                ])
              })
            )
          ])
        ])
    })
  ])
};
