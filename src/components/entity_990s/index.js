import { z, useContext, useMemo, useStream } from 'zorium'
import * as _ from 'lodash-es'
import * as rx from 'rxjs/operators'

import $icon from 'frontend-shared/components/icon'
import { pdfIconPath } from 'frontend-shared/components/icon/paths'

import colors from '../../colors'
import context from '../../context'

if (typeof window !== 'undefined' && window !== null) {
  require('./index.styl')
}

export default function $fund990s ({ entityStream, entityType }) {
  const { model, lang, router } = useContext(context)

  const { entity990sStream } = useMemo(() => {
    return {
      entity990sStream: entityStream.pipe(
        rx.switchMap(entity => model[`${entityType}990`].getAllByEin(entity.ein))
      )
    }
  }, [])

  const { entity990s } = useStream(() => ({
    entity990s: entity990sStream
  }))

  return z('.z-fund-990s', [
    z('.title', lang.get('fund990s.title')),
    z('.irs-990s',
      _.map(entity990s?.nodes, ({ ein, year, taxPeriod }, i) => {
        const folder1 = ein.substr(0, 3)
        return router.link(z('a.irs-990', {
          // TODO: https://www.irs.gov/charities-non-profits/tax-exempt-organization-search-bulk-data-downloads
          href: 'http://990s.foundationcenter.org/990pf_pdf_archive/' +
                `${folder1}/${ein}/${ein}_${taxPeriod}_990PF.pdf`
        }, [
          z('.icon', [
            z($icon, {
              icon: pdfIconPath,
              color: colors.$red500
            })
          ]),
          i === 0
            ? `${year} ${lang.get('fund990s.latestFiling')}`
            : `${year}`
        ]))
      })
    )
  ])
};
