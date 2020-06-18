import { z, useContext, useMemo, useStream } from 'zorium'
import * as _ from 'lodash-es'
import * as rx from 'rxjs/operators'

import $table from 'frontend-shared/components/table'
import FormatService from 'frontend-shared/services/format'

import context from '../../context'

if (typeof window !== 'undefined' && window !== null) {
  require('./index.styl')
}

export default function $entityPersons ({ entity, entityStream }) {
  const { model, browser, lang } = useContext(context)

  const { personsStream } = useMemo(() => ({
    personsStream: entityStream.pipe(
      rx.switchMap(entity =>
        model.irsPerson.getAllByEin(entity.ein, { limit: 100 })
          .pipe(
            rx.map((persons) => {
              persons = _.map(persons?.nodes, function (person) {
                const maxYear = _.maxBy(person.years, 'year')
                return _.defaults({ maxYear }, person)
              })
              persons = _.orderBy(persons, [
                ({ maxYear }) => maxYear.year,
                ({ maxYear }) => maxYear.compensation
              ], ['desc', 'desc'])
              return persons
            })
          )
      )
    )
  })
  , [])

  const { persons, breakpoint } = useStream(() => ({
    persons: personsStream,
    breakpoint: browser.getBreakpoint()
  }))

  return z('.z-entity-persons', [
    z('.persons', [
      z($table, {
        breakpoint,
        data: persons,
        mobileRowRenderer: $entityPersonsMobileRow,
        columns: [
          {
            key: 'name', name: lang.get('general.name'), isFlex: true
          },
          {
            key: 'title',
            name: lang.get('person.title'),
            isFlex: true,
            content ({ row }) {
              return row.maxYear.title
            }
          },
          {
            key: 'compensation',
            name: lang.get('person.compensation'),
            width: 200,
            content ({ row }) {
              return FormatService.abbreviateDollar(row.maxYear.compensation)
            }
          },
          {
            key: 'year',
            name: lang.get('person.years'),
            width: 150,
            content ({ row }) {
              return z('.z-entity-persons_years',
                FormatService.yearsArrayToEnglish(_.map(row.years, 'year')))
            }
          }
        ]
      })
    ])
  ])
};

function $entityPersonsMobileRow ({ row }) {
  const { lang } = useContext(context)

  return z('.z-entity-persons-mobile-row', [
    z('.name', row.name),
    z('.title', row.maxYear.title),
    z('.compensation', [
      lang.get('person.compensation'),
      ': ',
      FormatService.abbreviateDollar(row.maxYear.compensation)
    ]),
    z('.years', [
      lang.get('person.years'),
      ': ',
      FormatService.yearsArrayToEnglish(_.map(row.years, 'year'))
    ])
  ])
}
