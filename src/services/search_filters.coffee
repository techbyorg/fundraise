RxObservable = require('rxjs/Observable').Observable
require 'rxjs/add/observable/of'
RxBehaviorSubject = require('rxjs/BehaviorSubject').BehaviorSubject
RxReplaySubject = require('rxjs/ReplaySubject').ReplaySubject
require 'rxjs/add/operator/distinctUntilChanged'
_defaults = require 'lodash/defaults'
_isEmpty = require 'lodash/isEmpty'
_isEqual = require 'lodash/isEqual'
_filter = require 'lodash/filter'
_groupBy = require 'lodash/groupBy'
_map = require 'lodash/map'
_reduce = require 'lodash/reduce'
_some = require 'lodash/some'
_zipWith = require 'lodash/zipWith'

FormatService = require './format'

nteeMajors = ['A', 'B', 'C', 'D', 'E', 'F', 'G', 'H', 'I', 'J', 'K', 'L', 'M'
'N', 'O', 'P', 'Q', 'R', 'S', 'T', 'U', 'V', 'W', 'X', 'Y', 'Z']

states = {
  AL: 'Alabama', AK: 'Alaska', AZ: 'Arizona', AR: 'Arkansas', CA: 'California', CO: 'Colorado', CT: 'Connecticut', DE: 'Delaware', FL: 'Florida', GA: 'Georgia', HI: 'Hawaii', ID: 'Idaho', IL: 'Illinois', IN: 'Indiana', IA: 'Iowa', KS: 'Kansas', KY: 'Kentucky', LA: 'Louisiana', ME: 'Maine', MD: 'Maryland', MA: 'Massachusetts', MI: 'Michigan', MN: 'Minnesota', MS: 'Mississippi', MO: 'Missouri', MT: 'Montana', NE: 'Nebraska', NV: 'Nevada', NH: 'New Hampshire', NJ: 'New Jersey', NM: 'New Mexico', NY: 'New York', NC: 'North Carolina', ND: 'North Dakota', OH: 'Ohio', OK: 'Oklahoma', OR: 'Oregon', PA: 'Pennsylvania', RI: 'Rhode Island', SC: 'South Carolina', SD: 'South Dakota', TN: 'Tennessee', TX: 'Texas', UT: 'Utah', VT: 'Vermont', VA: 'Virginia', WA: 'Washington', WV: 'West Virginia', WI: 'Wisconsin', WY: 'Wyoming'
}

class SearchFiltersService
  getFundFilters: (model) ->
    [
      # search-tags. not in filter bar
      {
        id: 'fundedNteeMajor' # used as ref/key
        field: 'fundedNteeMajor'
        title: model.l.get 'filter.fundedNteeMajor.title'
        type: 'listOr'
        items: _map nteeMajors, (nteeMajor) ->
          {key: nteeMajor, label: model.l.get "nteeMajor.#{nteeMajor}"}
        queryFn: (value, key) ->
          {
            nested:
              path: 'fundedNteeMajors'
              query:
                bool:
                  must: [
                    {match: {'fundedNteeMajors.key': key}}
                    {range: {'fundedNteeMajors.percent': {gte: 2}}}
                  ]
          }
      }
      # search-tags, not in filter bar
      {
        id: 'state' # used as ref/key
        field: 'state'
        type: 'listOr'
        items: _map states, (state, stateCode) ->
          {key: stateCode, label: state}
        queryFn: (value, key) ->
          {
            nested:
              path: 'fundedStates'
              query:
                bool:
                  must: [
                    {match: {'fundedStates.key': key}}
                    {range: {'fundedStates.percent': {gte: 2}}}
                  ]
          }
      }

      {
        id: 'assets' # used as ref/key
        field: 'assets'
        type: 'minMax'
        name: model.l.get 'filter.assets'
        title: model.l.get 'filter.assetsTitle'
        minOptions: [
          {value: '0', text: model.l.get 'filter.noMin'}
          {value: '100000', text: FormatService.abbreviateDollar 100000}
          {value: '1000000', text: FormatService.abbreviateDollar 1000000}
          {value: '10000000', text: FormatService.abbreviateDollar 10000000}
          {value: '100000000', text: FormatService.abbreviateDollar 100000000}
          {value: '1000000000', text: FormatService.abbreviateDollar 1000000000}
          {value: '10000000000', text: FormatService.abbreviateDollar 10000000000} # 10b
        ]
        maxOptions: [
          {value: '0', text: model.l.get 'filter.noMax'}
          {value: '100000', text: FormatService.abbreviateDollar 100000}
          {value: '1000000', text: FormatService.abbreviateDollar 1000000}
          {value: '10000000', text: FormatService.abbreviateDollar 10000000}
          {value: '100000000', text: FormatService.abbreviateDollar 100000000}
          {value: '1000000000', text: FormatService.abbreviateDollar 1000000000}
          {value: '10000000000', text: FormatService.abbreviateDollar 10000000000} # 10b
        ]
      }
      {
        id: 'lastYearStats.grantSum' # used as ref/key
        field: 'lastYearStats.grantSum'
        type: 'minMax'
        name: model.l.get 'filter.grantSum'
        minOptions: [
          {value: '0', text: model.l.get 'filter.noMin'}
          {value: '10000', text: FormatService.abbreviateDollar 10000}
          {value: '100000', text: FormatService.abbreviateDollar 100000}
          {value: '1000000', text: FormatService.abbreviateDollar 1000000}
          {value: '10000000', text: FormatService.abbreviateDollar 10000000}
          {value: '100000000', text: FormatService.abbreviateDollar 100000000}
          {value: '1000000000', text: FormatService.abbreviateDollar 1000000000} # 1b
        ]
        maxOptions: [
          {value: '0', text: model.l.get 'filter.noMax'}
          {value: '10000', text: FormatService.abbreviateDollar 10000}
          {value: '100000', text: FormatService.abbreviateDollar 100000}
          {value: '1000000', text: FormatService.abbreviateDollar 1000000}
          {value: '10000000', text: FormatService.abbreviateDollar 10000000}
          {value: '100000000', text: FormatService.abbreviateDollar 100000000}
          {value: '1000000000', text: FormatService.abbreviateDollar 1000000000} # 1b
        ]
      }
      {
        id: 'lastYearStats.grantMedian' # used as ref/key
        field: 'lastYearStats.grantMedian'
        type: 'minMax'
        name: model.l.get 'filter.grantMedian'
        minOptions: [
          {value: '0', text: model.l.get 'filter.noMin'}
          {value: '1000', text: FormatService.abbreviateDollar 1000}
          {value: '10000', text: FormatService.abbreviateDollar 10000}
          {value: '100000', text: FormatService.abbreviateDollar 100000}
          {value: '1000000', text: FormatService.abbreviateDollar 1000000}
          {value: '10000000', text: FormatService.abbreviateDollar 10000000}
          {value: '100000000', text: FormatService.abbreviateDollar 100000000} # 100m
        ]
        maxOptions: [
          {value: '0', text: model.l.get 'filter.noMax'}
          {value: '1000', text: FormatService.abbreviateDollar 1000}
          {value: '10000', text: FormatService.abbreviateDollar 10000}
          {value: '100000', text: FormatService.abbreviateDollar 100000}
          {value: '1000000', text: FormatService.abbreviateDollar 1000000}
          {value: '10000000', text: FormatService.abbreviateDollar 10000000}
          {value: '100000000', text: FormatService.abbreviateDollar 100000000} # 100m
        ]
      }
  ]

  getFiltersStream: ({model, filters, initialFilters, dataType = 'irsFund'}) ->
    # eg filters from custom urls
    initialFilters ?= new RxBehaviorSubject null
    initialFilters.switchMap (initialFilters) =>
      persistentCookie = 'savedFilters'
      savedFilters = try
        JSON.parse model.cookie.get persistentCookie
      catch
        {}

      filters = _map filters, (filter) =>
        if filter.type is 'booleanArray'
          savedValueKey = "#{dataType}.#{filter.field}.#{filter.arrayValue}"
        else
          savedValueKey = "#{dataType}.#{filter.field}"

        initialValue = if initialFilters \
                       then initialFilters[savedValueKey] \
                       else savedFilters[savedValueKey]

        valueStreams = new RxReplaySubject 1
        valueStreams.next RxObservable.of(
          if initialValue? then initialValue else filter.defaultValue
        )

        _defaults {dataType, valueStreams}, filter

      if _isEmpty filters
        return RxObservable.of {}

      RxObservable.combineLatest(
        _map filters, ({valueStreams}) -> valueStreams.switch()
        (vals...) -> vals
      )
      # ^^ updates a lot since $filterContent sets valueStreams on a lot
      # on load. this prevents a bunch of extra lodash loops from getting called
      .distinctUntilChanged _isEqual
      .map (values) =>
        filtersWithValue = _zipWith filters, values, (filter, value) ->
          _defaults {value}, filter

        # set cookie to persist filters
        savedFilters = _reduce filtersWithValue, (obj, filter) ->
          {dataType, field, value, type, arrayValue} = filter
          if value? and type is 'booleanArray'
            obj["#{dataType}.#{field}.#{arrayValue}"] = value
          else if value?
            obj["#{dataType}.#{field}"] = value
          obj
        , {}
        model.cookie.set persistentCookie, JSON.stringify savedFilters

        filtersWithValue

    # for whatever reason, required for stream to update, unless the
    # initialFilters switchMap is removed
    .publishReplay(1).refCount()


  getESQueryFilterFromFilters: (filters) =>
    groupedFilters = _groupBy filters, 'field'
    filter = _filter _map groupedFilters, (fieldFilters, field) =>
      unless _some fieldFilters, 'value'
        return

      filter = fieldFilters[0]

      switch filter.type
        when 'maxInt', 'maxIntCustom'
          {
            range:
              "#{field}":
                lte: filter.value
          }
        when 'minInt', 'minIntCustom'
          {
            range:
              "#{field}":
                gte: filter.value
          }
        when 'gtlt'
          if filter.value.operator and filter.value.value
            {
              range:
                "#{field}":
                  "#{filter.value.operator}": filter.value.value
            }
        when 'minMax'
          min =  filter.value.min
          max =  filter.value.max
          if min or max
            range = {}
            if min
              range.gte = min
            # if max
            #   range.lte = max
            {
              range:
                "#{field}": range
            }
        when 'gtZero'
          {
            range:
              "#{field}":
                gt: 0
          }
        when 'listAnd', 'listBooleanAnd'
          {
            bool:
              must: _filter _map filter.value, (value, key) ->
                if value and filter.queryFn
                  filter.queryFn value, key
                else if value
                  match: "#{field}.#{key}": value
          }
        when 'listBooleanOr', 'listOr'
          {
            bool:
              should: _filter _map filter.value, (value, key) ->
                if value and filter.queryFn
                  filter.queryFn value, key
                else if value
                  match: "#{field}.#{key}": value
          }
        when 'fieldList'
          {
            bool:
              should: _filter _map filter.value, (value, key) ->
                if value
                  match: "#{field}": key
          }
        when 'booleanArray'
          withValues = _filter(fieldFilters, 'value')

          {
            # there's potentially a cleaner way to do this?
            bool:
              should: _map withValues, ({value, arrayValue, valueFn}) ->
                # if subtypes are specified
                if typeof value is 'object'
                  bool:
                    must: [
                      {match: "#{field}": arrayValue}
                      bool:
                        should: valueFn value
                    ]
                else
                  {match: "#{field}": arrayValue}

            }

    filter


module.exports = new SearchFiltersService()
