import { z, classKebab, useContext, useMemo, useStream } from 'zorium'
import * as _ from 'lodash-es'
import * as Rx from 'rxjs'
import * as rx from 'rxjs/operators'

import $tapTabs from 'frontend-shared/components/tap_tabs'

import $entity990s from '../entity_990s'
import $entityAtAGlance from '../entity_at_a_glance'
import $entityPersons from '../entity_persons'
import $fundApplicationInfo from '../fund_application_info'
import $fundOverview from '../fund_overview'
import $fundGrants from '../fund_grants'
import $orgOverview from '../org_overview'
import context from '../../context'

if (typeof window !== 'undefined') { require('./index.styl') }

export default function $entity (props) {
  const { placeholderNameStream, entityStream, tabStream, entityType } = props
  const { lang, router } = useContext(context)

  const { selectedIndexStreams } = useMemo(() => {
    const selectedIndexStreams = new Rx.ReplaySubject(1)
    selectedIndexStreams.next(
      tabStream.pipe(rx.map((tab) => {
        console.log('check', tabs, tab)
        let index = _.findIndex(tabs, { slug: tab })
        if (index === -1) {
          index = 0
        }
        return index
      }))
    )
    return { selectedIndexStreams }
  }, [])

  let { entity, selectedIndex } = useStream(() => ({
    entity: entityStream,
    selectedIndex: selectedIndexStreams.pipe(rx.switchAll())
  }))

  const tabs = _.filter([
    {
      name: lang.get(`${entityType}.tabOverview`),
      slug: 'overview',
      route: entityType === 'irsOrg'
        ? router.getOrg(entity, 'overview')
        : router.getFund(entity, 'overview'),
      $el: entityType === 'irsOrg'
        ? $orgOverview
        : $fundOverview
    },
    entityType === 'irsFund' && {
      name: lang.get('entity.tabGrants'),
      slug: 'grants',
      route: entityType === 'irsOrg'
        ? router.getOrg(entity, 'grants')
        : router.getFund(entity, 'grants'),
      $el: $fundGrants
    },
    {
      name: lang.get('entity.tabPersons'),
      slug: 'persons',
      route: entityType === 'irsOrg'
        ? router.getOrg(entity, 'persons')
        : router.getFund(entity, 'persons'),
      $el: $entityPersons
    },
    entityType === 'irsFund' && {
      name: lang.get('irsFund.tabApplicationInfo'),
      slug: 'application-info',
      route: entityType === 'irsOrg'
        ? router.getOrg(entity, 'application-info')
        : router.getFund(entity, 'application-info'),
      $el: $fundApplicationInfo
    },
    {
      name: lang.get('entity.tab990s'),
      slug: '990s',
      route: entityType === 'irsOrg'
        ? router.getOrg(entity, '990s')
        : router.getFund(entity, '990s'),
      $el: $entity990s
    }
  ])

  selectedIndex = selectedIndex || 0

  const selectedTab = tabs[selectedIndex]

  return z('.z-entity', {
    className: classKebab({
      scrollFitContent: !(['grants', 'persons'].includes(selectedTab.slug))
    })
  }, [
    z('.quick-info', [
      z($entityAtAGlance, { placeholderNameStream, entity, entityType })
    ]),
    z('.content', [
      z('.inner', [
        z($tapTabs, {
          selectedIndexStreams,
          tabs,
          tabProps: { entity, entityStream, entityType }
        })
      ])
    ])
  ])
}
