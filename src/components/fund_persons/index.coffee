import {z, useContext, useMemo, useStream} from 'zorium'
import _defaults from 'lodash/defaults'
import _orderBy from 'lodash/orderBy'
import _maxBy from 'lodash/maxBy'
import _map from 'lodash/map'

import $table from 'frontend-shared/components/table'
import FormatService from 'frontend-shared/services/format'

import context from '../../context'

if window?
  require './index.styl'

export default $fundPersons = ({irsFund, irsFundStream}) ->
  {model, lang} = useContext context

  {personsStream} = useMemo ->
    {
      personsStream: irsFundStream.switchMap (irsFund) ->
        model.irsPerson.getAllByEin irsFund.ein, {limit: 100}
        .map (persons) ->
          persons = _map persons?.nodes, (person) ->
            maxYear = _maxBy person.years, 'year'
            _defaults {maxYear}, person
          persons = _orderBy persons, [
            ({maxYear}) -> maxYear.year
            ({maxYear}) -> maxYear.compensation
          ], ['desc', 'desc']
    }
  , []

  {persons} = useStream ->
    persons: personsStream

  z '.z-fund-persons',
    z '.persons',
      z $table,
        data: persons
        mobileRowRenderer: $fundPersonsMobileRow
        columns: [
          {
            key: 'name', name: lang.get('general.name'), isFlex: true
          }
          {
            key: 'title', name: lang.get('person.title'), isFlex: true
            content: ({row}) ->
              row.maxYear.title
          }
          {
            key: 'compensation', name: lang.get('person.compensation'), width: 200
            content: ({row}) ->
              FormatService.abbreviateDollar row.maxYear.compensation
          }
          {
            key: 'year', name: lang.get('person.years'), width: 150
            content: ({row}) ->
              z '.z-fund-persons_years',
                FormatService.yearsArrayToEnglish _map(row.years, 'year')
          }
        ]

$fundPersonsMobileRow = ({row}) ->
  {lang} = useContext context

  z '.z-fund-persons-mobile-row',
    z '.name', row.name
    z '.title', row.maxYear.title
    z '.compensation',
      lang.get 'person.compensation'
      ': '
      FormatService.abbreviateDollar row.maxYear.compensation
    z '.years',
      lang.get 'person.years'
      ': '
      FormatService.yearsArrayToEnglish _map(row.years, 'year')
