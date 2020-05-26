{z, useMemo, useStream} = require 'zorium'
_defaults = require 'lodash/defaults'
_orderBy = require 'lodash/orderBy'
_maxBy = require 'lodash/maxBy'
_map = require 'lodash/map'

$table = require '../table'
FormatService = require '../../services/format'

if window?
  require './index.styl'

module.exports = $fundPersons = ({model, router, irsFund, irsFundStream}) ->
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
        model: model
        router: router
        data: persons
        mobileRowRenderer: $fundPersonsMobileRow
        columns: [
          {
            key: 'name', name: model.l.get('general.name'), isFlex: true
          }
          {
            key: 'title', name: model.l.get('person.title'), isFlex: true
            content: ({row}) ->
              row.maxYear.title
          }
          {
            key: 'compensation', name: model.l.get('person.compensation'), width: 200
            content: ({row}) ->
              FormatService.abbreviateDollar row.maxYear.compensation
          }
          {
            key: 'year', name: model.l.get('person.years'), width: 150
            content: ({row}) ->
              z '.z-fund-persons_years',
                FormatService.yearsArrayToEnglish _map(row.years, 'year')
          }
        ]

$fundPersonsMobileRow = ({model, row}) ->
  z '.z-fund-persons-mobile-row',
    z '.name', row.name
    z '.title', row.maxYear.title
    z '.compensation',
      model.l.get 'person.compensation'
      ': '
      FormatService.abbreviateDollar row.maxYear.compensation
    z '.years',
      model.l.get 'person.years'
      ': '
      FormatService.yearsArrayToEnglish _map(row.years, 'year')
