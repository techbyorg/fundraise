import * as _ from 'lodash-es'
import * as Rx from 'rxjs'
import * as rx from 'rxjs/operators'

import FormatService from 'frontend-shared/services/format'

nteeMajors = ['A', 'B', 'C', 'D', 'E', 'F', 'G', 'H', 'I', 'J', 'K', 'L', 'M'
'N', 'O', 'P', 'Q', 'R', 'S', 'T', 'U', 'V', 'W', 'X', 'Y', 'Z']

states = {
  AL: 'Alabama', AK: 'Alaska', AZ: 'Arizona', AR: 'Arkansas', CA: 'California', CO: 'Colorado', CT: 'Connecticut', DE: 'Delaware', FL: 'Florida', GA: 'Georgia', HI: 'Hawaii', ID: 'Idaho', IL: 'Illinois', IN: 'Indiana', IA: 'Iowa', KS: 'Kansas', KY: 'Kentucky', LA: 'Louisiana', ME: 'Maine', MD: 'Maryland', MA: 'Massachusetts', MI: 'Michigan', MN: 'Minnesota', MS: 'Mississippi', MO: 'Missouri', MT: 'Montana', NE: 'Nebraska', NV: 'Nevada', NH: 'New Hampshire', NJ: 'New Jersey', NM: 'New Mexico', NY: 'New York', NC: 'North Carolina', ND: 'North Dakota', OH: 'Ohio', OK: 'Oklahoma', OR: 'Oregon', PA: 'Pennsylvania', RI: 'Rhode Island', SC: 'South Carolina', SD: 'South Dakota', TN: 'Tennessee', TX: 'Texas', UT: 'Utah', VT: 'Vermont', VA: 'Virginia', WA: 'Washington', WV: 'West Virginia', WI: 'Wisconsin', WY: 'Wyoming'
}

class SearchFiltersService
  getFundFilters: (lang) ->
    [
      # search-tags. not in filter bar
      {
        id: 'fundedNteeMajor' # used as ref/key
        field: 'fundedNteeMajor'
        title: lang.get 'filter.fundedNteeMajor.title'
        type: 'listOr'
        items: _.map nteeMajors, (nteeMajor) ->
          {key: nteeMajor, label: lang.get "nteeMajor.#{nteeMajor}"}
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
        title: lang.get 'filter.fundedStates.title'
        type: 'listOr'
        items: _.map states, (state, stateCode) ->
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
        name: lang.get 'filter.assets'
        title: lang.get 'filter.assetsTitle'
        minOptions: [
          {value: '0', text: lang.get 'filter.noMin'}
          {value: '100000', text: FormatService.abbreviateDollar 100000}
          {value: '1000000', text: FormatService.abbreviateDollar 1000000}
          {value: '10000000', text: FormatService.abbreviateDollar 10000000}
          {value: '100000000', text: FormatService.abbreviateDollar 100000000}
          {value: '1000000000', text: FormatService.abbreviateDollar 1000000000}
          {value: '10000000000', text: FormatService.abbreviateDollar 10000000000} # 10b
        ]
        maxOptions: [
          {value: '0', text: lang.get 'filter.noMax'}
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
        name: lang.get 'filter.grantSum'
        minOptions: [
          {value: '0', text: lang.get 'filter.noMin'}
          {value: '10000', text: FormatService.abbreviateDollar 10000}
          {value: '100000', text: FormatService.abbreviateDollar 100000}
          {value: '1000000', text: FormatService.abbreviateDollar 1000000}
          {value: '10000000', text: FormatService.abbreviateDollar 10000000}
          {value: '100000000', text: FormatService.abbreviateDollar 100000000}
          {value: '1000000000', text: FormatService.abbreviateDollar 1000000000} # 1b
        ]
        maxOptions: [
          {value: '0', text: lang.get 'filter.noMax'}
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
        name: lang.get 'filter.grantMedian'
        minOptions: [
          {value: '0', text: lang.get 'filter.noMin'}
          {value: '1000', text: FormatService.abbreviateDollar 1000}
          {value: '10000', text: FormatService.abbreviateDollar 10000}
          {value: '100000', text: FormatService.abbreviateDollar 100000}
          {value: '1000000', text: FormatService.abbreviateDollar 1000000}
          {value: '10000000', text: FormatService.abbreviateDollar 10000000}
          {value: '100000000', text: FormatService.abbreviateDollar 100000000} # 100m
        ]
        maxOptions: [
          {value: '0', text: lang.get 'filter.noMax'}
          {value: '1000', text: FormatService.abbreviateDollar 1000}
          {value: '10000', text: FormatService.abbreviateDollar 10000}
          {value: '100000', text: FormatService.abbreviateDollar 100000}
          {value: '1000000', text: FormatService.abbreviateDollar 1000000}
          {value: '10000000', text: FormatService.abbreviateDollar 10000000}
          {value: '100000000', text: FormatService.abbreviateDollar 100000000} # 100m
        ]
      }
  ]

  getFiltersStream: ({cookie, filters, initialFilters, dataType = 'irsFund'}) ->
    # eg filters from custom urls
    initialFilters ?= new Rx.BehaviorSubject null
    initialFilters = initialFilters.pipe rx.switchMap (initialFilters) =>
      persistentCookie = 'savedFilters'
      savedFilters = try
        JSON.parse cookie.get persistentCookie
      catch
        {}

      console.log 'saved filters', persistentCookie, savedFilters

      filters = _.map filters, (filter) =>
        if filter.type is 'booleanArray'
          savedValueKey = "#{dataType}.#{filter.field}.#{filter.arrayValue}"
        else
          savedValueKey = "#{dataType}.#{filter.field}"

        initialValue = if initialFilters \
                       then initialFilters[savedValueKey] \
                       else savedFilters[savedValueKey]

        valueStreams = new Rx.ReplaySubject 1
        valueStreams.next Rx.of(
          if initialValue? then initialValue else filter.defaultValue
        )

        _.defaults {dataType, valueStreams}, filter

      if _.isEmpty filters
        return Rx.of {}

      Rx.combineLatest(
        _.map filters, ({valueStreams}) -> valueStreams.pipe rx.switchAll()
        (vals...) -> vals
      )
      # ^^ updates a lot since $filterContent sets valueStreams on a lot
      # on load. this prevents a bunch of extra lodash loops from getting called
      .pipe(
        rx.distinctUntilChanged _.isEqual
        rx.map (values) =>
          filtersWithValue = _.zipWith filters, values, (filter, value) ->
            _.defaults {value}, filter

          # set cookie to persist filters
          savedFilters = _.reduce filtersWithValue, (obj, filter) ->
            {dataType, field, value, type, arrayValue} = filter
            if value? and type is 'booleanArray'
              obj["#{dataType}.#{field}.#{arrayValue}"] = value
            else if value?
              obj["#{dataType}.#{field}"] = value
            obj
          , {}
          cookie.set persistentCookie, JSON.stringify savedFilters

          filtersWithValue
      )

    # for whatever reason, required for stream to update, unless the
    # initialFilters switchMap is removed
    initialFilters.pipe(
      rx.publishReplay(1)
      rx.refCount()
    )


  getESQueryFilterFromFilters: (filters) =>
    groupedFilters = _.groupBy filters, 'field'
    filter = _.filter _.map groupedFilters, (fieldFilters, field) =>
      unless _.some fieldFilters, 'value'
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
              must: _.filter _.map filter.value, (value, key) ->
                if value and filter.queryFn
                  filter.queryFn value, key
                else if value
                  match: "#{field}.#{key}": value
          }
        when 'listBooleanOr', 'listOr'
          {
            bool:
              should: _.filter _.map filter.value, (value, key) ->
                if value and filter.queryFn
                  filter.queryFn value, key
                else if value
                  match: "#{field}.#{key}": value
          }
        when 'fieldList'
          {
            bool:
              should: _.filter _.map filter.value, (value, key) ->
                if value
                  match: "#{field}": key
          }
        when 'booleanArray'
          withValues = _.filter(fieldFilters, 'value')

          {
            # there's potentially a cleaner way to do this?
            bool:
              should: _.map withValues, ({value, arrayValue, valueFn}) ->
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


export default new SearchFiltersService()
