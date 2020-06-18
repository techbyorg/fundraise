import * as _ from 'lodash-es'
import * as Rx from 'rxjs'
import * as rx from 'rxjs/operators'

import FormatService from 'frontend-shared/services/format'

import { nteeColors } from '../colors'

const states = {
  AL: 'Alabama', AK: 'Alaska', AZ: 'Arizona', AR: 'Arkansas', CA: 'California', CO: 'Colorado', CT: 'Connecticut', DE: 'Delaware', FL: 'Florida', GA: 'Georgia', HI: 'Hawaii', ID: 'Idaho', IL: 'Illinois', IN: 'Indiana', IA: 'Iowa', KS: 'Kansas', KY: 'Kentucky', LA: 'Louisiana', ME: 'Maine', MD: 'Maryland', MA: 'Massachusetts', MI: 'Michigan', MN: 'Minnesota', MS: 'Mississippi', MO: 'Missouri', MT: 'Montana', NE: 'Nebraska', NV: 'Nevada', NH: 'New Hampshire', NJ: 'New Jersey', NM: 'New Mexico', NY: 'New York', NC: 'North Carolina', ND: 'North Dakota', OH: 'Ohio', OK: 'Oklahoma', OR: 'Oregon', PA: 'Pennsylvania', RI: 'Rhode Island', SC: 'South Carolina', SD: 'South Dakota', TN: 'Tennessee', TX: 'Texas', UT: 'Utah', VT: 'Vermont', VA: 'Virginia', WA: 'Washington', WV: 'West Virginia', WI: 'Wisconsin', WY: 'Wyoming'
}

function nteeGetTagsFn (lang) {
  return (value = {}) => {
    const { nteeMajors, ntees } = value
    const nteeMajorsGroups = _.countBy(_.keys(ntees), ntee =>
      ntee.substr(0, 1)
    )
    const allNteeMajors = _.defaults(_.clone(nteeMajors), nteeMajorsGroups)
    return _.map(allNteeMajors, (count, nteeMajor) => {
      let text = lang.get(`nteeMajor.${nteeMajor}`)
      if (count !== true) {
        text = `(${count}) ${text}`
      }
      return {
        text,
        background: nteeColors[nteeMajor]?.bg,
        color: nteeColors[nteeMajor]?.fg
      }
    })
  }
}

class SearchFiltersService {
  constructor () {
    this.getESQueryFilterFromFilters = this.getESQueryFilterFromFilters.bind(this)
  }

  getFundFilters (lang) {
    return [
      // search-tags. not in filter bar
      {
        id: 'fundedNteeMajor', // used as ref/key
        field: 'fundedNteeMajor',
        title: lang.get('filter.fundedNteeMajor.title'),
        type: 'fundedNtee',
        getTagsFn: nteeGetTagsFn(lang)
      },
      // search-tags, not in filter bar
      {
        id: 'state', // used as ref/key
        field: 'state',
        title: lang.get('filter.fundedStates.title'),
        type: 'listOr',
        items: _.mapValues(states, (state, stateCode) => ({
          label: state
        })),
        getTagsFn: (value) => {
          return _.filter(_.map(value, (val, key) => {
            if (val) {
              return { text: states[key] }
            }
          }))
        },
        queryFn: (value, key) => {
          return {
            nested: {
              path: 'fundedStates',
              query: {
                bool: {
                  must: [
                    { match: { 'fundedStates.key': key } },
                    { range: { 'fundedStates.percent': { gte: 2 } } }
                  ]
                }
              }
            }
          }
        }
      },

      {
        id: 'assets', // used as ref/key
        field: 'assets',
        type: 'minMax',
        name: lang.get('filter.assets'),
        title: lang.get('filter.assetsTitle'),
        minOptions: [
          { value: '0', text: lang.get('filter.noMin') },
          { value: '100000', text: FormatService.abbreviateDollar(100000) },
          { value: '1000000', text: FormatService.abbreviateDollar(1000000) },
          { value: '10000000', text: FormatService.abbreviateDollar(10000000) },
          { value: '100000000', text: FormatService.abbreviateDollar(100000000) },
          { value: '1000000000', text: FormatService.abbreviateDollar(1000000000) },
          { value: '10000000000', text: FormatService.abbreviateDollar(10000000000) } // 10b
        ],
        maxOptions: [
          { value: '0', text: lang.get('filter.noMax') },
          { value: '100000', text: FormatService.abbreviateDollar(100000) },
          { value: '1000000', text: FormatService.abbreviateDollar(1000000) },
          { value: '10000000', text: FormatService.abbreviateDollar(10000000) },
          { value: '100000000', text: FormatService.abbreviateDollar(100000000) },
          { value: '1000000000', text: FormatService.abbreviateDollar(1000000000) },
          { value: '10000000000', text: FormatService.abbreviateDollar(10000000000) } // 10b
        ]
      },
      {
        id: 'lastYearStats.grantSum', // used as ref/key
        field: 'lastYearStats.grantSum',
        type: 'minMax',
        name: lang.get('filter.grantSum'),
        minOptions: [
          { value: '0', text: lang.get('filter.noMin') },
          { value: '10000', text: FormatService.abbreviateDollar(10000) },
          { value: '100000', text: FormatService.abbreviateDollar(100000) },
          { value: '1000000', text: FormatService.abbreviateDollar(1000000) },
          { value: '10000000', text: FormatService.abbreviateDollar(10000000) },
          { value: '100000000', text: FormatService.abbreviateDollar(100000000) },
          { value: '1000000000', text: FormatService.abbreviateDollar(1000000000) } // 1b
        ],
        maxOptions: [
          { value: '0', text: lang.get('filter.noMax') },
          { value: '10000', text: FormatService.abbreviateDollar(10000) },
          { value: '100000', text: FormatService.abbreviateDollar(100000) },
          { value: '1000000', text: FormatService.abbreviateDollar(1000000) },
          { value: '10000000', text: FormatService.abbreviateDollar(10000000) },
          { value: '100000000', text: FormatService.abbreviateDollar(100000000) },
          { value: '1000000000', text: FormatService.abbreviateDollar(1000000000) } // 1b
        ]
      },
      {
        id: 'lastYearStats.grantMedian', // used as ref/key
        field: 'lastYearStats.grantMedian',
        type: 'minMax',
        name: lang.get('filter.grantMedian'),
        minOptions: [
          { value: '0', text: lang.get('filter.noMin') },
          { value: '1000', text: FormatService.abbreviateDollar(1000) },
          { value: '10000', text: FormatService.abbreviateDollar(10000) },
          { value: '100000', text: FormatService.abbreviateDollar(100000) },
          { value: '1000000', text: FormatService.abbreviateDollar(1000000) },
          { value: '10000000', text: FormatService.abbreviateDollar(10000000) },
          { value: '100000000', text: FormatService.abbreviateDollar(100000000) } // 100m
        ],
        maxOptions: [
          { value: '0', text: lang.get('filter.noMax') },
          { value: '1000', text: FormatService.abbreviateDollar(1000) },
          { value: '10000', text: FormatService.abbreviateDollar(10000) },
          { value: '100000', text: FormatService.abbreviateDollar(100000) },
          { value: '1000000', text: FormatService.abbreviateDollar(1000000) },
          { value: '10000000', text: FormatService.abbreviateDollar(10000000) },
          { value: '100000000', text: FormatService.abbreviateDollar(100000000) } // 100m
        ]
      },
      {
        id: 'acceptsUnsolicitedReqs', // used as ref/key
        field: 'applicantInfo.acceptsUnsolicitedRequests',
        name: lang.get('filter.acceptsUnsolicitedReqs.title'),
        type: 'boolean',
        isBoolean: true
      }
    ]
  }

  getOrgFilters (lang) {
    return [
      // search-tags. not in filter bar
      {
        id: 'fundedNteeMajor', // used as ref/key
        field: 'nteeMajor',
        title: lang.get('filter.fundedNteeMajor.title'),
        type: 'ntee',
        getTagsFn: nteeGetTagsFn(lang)
      },
      // search-tags, not in filter bar
      {
        id: 'state', // used as ref/key
        field: 'state',
        title: lang.get('filter.fundedStates.title'),
        type: 'listOr',
        items: _.mapValues(states, (state, stateCode) => ({
          label: state
        })),
        getTagsFn: (value) => {
          return _.filter(_.map(value, (val, key) => {
            if (val) {
              return { text: states[key] }
            }
          }))
        },
        queryFn: (value, key) => {
          return { match: { state: key } }
        }
      },
      {
        id: 'assets', // used as ref/key
        field: 'assets',
        type: 'minMax',
        name: lang.get('filter.assets'),
        minOptions: [
          { value: '0', text: lang.get('filter.noMin') },
          { value: '10000', text: FormatService.abbreviateDollar(10000) },
          { value: '100000', text: FormatService.abbreviateDollar(100000) },
          { value: '1000000', text: FormatService.abbreviateDollar(1000000) },
          { value: '10000000', text: FormatService.abbreviateDollar(10000000) },
          { value: '100000000', text: FormatService.abbreviateDollar(100000000) },
          { value: '1000000000', text: FormatService.abbreviateDollar(1000000000) } // 1b
        ],
        maxOptions: [
          { value: '0', text: lang.get('filter.noMax') },
          { value: '10000', text: FormatService.abbreviateDollar(10000) },
          { value: '100000', text: FormatService.abbreviateDollar(100000) },
          { value: '1000000', text: FormatService.abbreviateDollar(1000000) },
          { value: '10000000', text: FormatService.abbreviateDollar(10000000) },
          { value: '100000000', text: FormatService.abbreviateDollar(100000000) },
          { value: '1000000000', text: FormatService.abbreviateDollar(1000000000) } // 1b
        ]
      },
      {
        id: 'employeeCount', // used as ref/key
        field: 'employeeCount',
        type: 'minMax',
        name: lang.get('filter.employeeCount'),
        minOptions: [
          { value: '0', text: lang.get('filter.noMin') },
          { value: '1', text: FormatService.abbreviateNumber(1) },
          { value: '5', text: FormatService.abbreviateNumber(5) },
          { value: '10', text: FormatService.abbreviateNumber(10) },
          { value: '100', text: FormatService.abbreviateNumber(100) },
          { value: '1000', text: FormatService.abbreviateNumber(1000) },
          { value: '10000', text: FormatService.abbreviateNumber(10000) }
        ],
        maxOptions: [
          { value: '0', text: lang.get('filter.noMax') },
          { value: '1', text: FormatService.abbreviateNumber(1) },
          { value: '5', text: FormatService.abbreviateNumber(5) },
          { value: '10', text: FormatService.abbreviateNumber(10) },
          { value: '100', text: FormatService.abbreviateNumber(100) },
          { value: '1000', text: FormatService.abbreviateNumber(1000) },
          { value: '10000', text: FormatService.abbreviateNumber(10000) }
        ]
      },
      {
        id: 'volunteerCount', // used as ref/key
        field: 'volunteerCount',
        type: 'minMax',
        name: lang.get('filter.volunteerCount'),
        minOptions: [
          { value: '0', text: lang.get('filter.noMin') },
          { value: '1', text: FormatService.abbreviateNumber(1) },
          { value: '5', text: FormatService.abbreviateNumber(5) },
          { value: '10', text: FormatService.abbreviateNumber(10) },
          { value: '100', text: FormatService.abbreviateNumber(100) },
          { value: '1000', text: FormatService.abbreviateNumber(1000) },
          { value: '10000', text: FormatService.abbreviateNumber(10000) }
        ],
        maxOptions: [
          { value: '0', text: lang.get('filter.noMax') },
          { value: '1', text: FormatService.abbreviateNumber(1) },
          { value: '5', text: FormatService.abbreviateNumber(5) },
          { value: '10', text: FormatService.abbreviateNumber(10) },
          { value: '100', text: FormatService.abbreviateNumber(100) },
          { value: '1000', text: FormatService.abbreviateNumber(1000) },
          { value: '10000', text: FormatService.abbreviateNumber(10000) }
        ]
      },
      {
        id: 'keywords', // used as ref/key
        field: 'keywords',
        fields: ['websiteText', 'mission'],
        type: 'keywords',
        name: lang.get('filter.keywords'),
        placeholder: lang.get('filter.keywords')
      },
      {
        id: 'city', // used as ref/key
        field: 'city',
        fields: ['city'],
        type: 'searchPhrase',
        name: lang.get('filter.city'),
        placeholder: lang.get('filter.city')
      }
    ]
  }

  getFiltersStream (props) {
    const { cookie } = props
    let {
      initialFiltersStream, filters, persistentCookie, dataType = 'irsFund'
    } = props

    // eg filters from custom urls
    if (initialFiltersStream == null) { initialFiltersStream = new Rx.BehaviorSubject(null) }
    initialFiltersStream = initialFiltersStream.pipe(rx.switchMap(initialFilters => {
      let savedFilters = (() => {
        try {
          return JSON.parse(cookie.get(persistentCookie))
        } catch (error) {
          return {}
        }
      })()

      console.log('saved filters', persistentCookie, savedFilters)

      filters = _.map(filters, filter => {
        let savedValueKey
        if (filter.type === 'booleanArray') {
          savedValueKey = `${dataType}.${filter.field}.${filter.arrayValue}`
        } else {
          savedValueKey = `${dataType}.${filter.field}`
        }

        const initialValue = !_.isEmpty(initialFilters)
          ? initialFilters[savedValueKey]
          : savedFilters[savedValueKey]

        console.log('initial', initialValue, savedValueKey, initialFilters)

        const valueStreams = new Rx.ReplaySubject(1)
        valueStreams.next(Rx.of(
          (initialValue != null) ? initialValue : filter.defaultValue
        )
        )

        return _.defaults({ dataType, valueStreams }, filter)
      })

      if (_.isEmpty(filters)) {
        return Rx.of({})
      }

      return Rx.combineLatest(
        _.map(filters, ({ valueStreams }) => valueStreams.pipe(rx.switchAll())),
        (...vals) => vals)
      // ^^ updates a lot since $filterContent sets valueStreams on a lot
      // on load. this prevents a bunch of extra lodash loops from getting called
        .pipe(
          rx.distinctUntilChanged(_.isEqual),
          rx.map(values => {
            const filtersWithValue = _.zipWith(filters, values, (filter, value) =>
              _.defaults({ value }, filter)
            )

            // set cookie to persist filters
            savedFilters = _.reduce(filtersWithValue, (obj, filter) => {
              let arrayValue, field, type, value;
              ({ dataType, field, value, type, arrayValue } = filter)
              if ((value != null) && (type === 'booleanArray')) {
                obj[`${dataType}.${field}.${arrayValue}`] = value
              } else if (value != null) {
                obj[`${dataType}.${field}`] = value
              }
              return obj
            }
            , {})
            cookie.set(persistentCookie, JSON.stringify(savedFilters))

            return filtersWithValue
          })
        )
    })
    )

    // for whatever reason, required for stream to update, unless the
    // initialFiltersStream switchMap is removed
    return initialFiltersStream.pipe(
      rx.publishReplay(1),
      rx.refCount()
    )
  }

  getESQueryFilterFromFilters (filters) {
    const groupedFilters = _.groupBy(filters, 'field')
    var filter = _.filter(_.map(groupedFilters, (fieldFilters, field) => {
      let range
      if (!_.some(fieldFilters, 'value')) {
        return
      }

      filter = fieldFilters[0]

      switch (filter.type) {
        case 'maxInt': case 'maxIntCustom':
          return {
            range: {
              [field]: {
                lte: filter.value
              }
            }
          }
        case 'minInt': case 'minIntCustom':
          return {
            range: {
              [field]: {
                gte: filter.value
              }
            }
          }
        case 'keywords':
          return {
            bool: {
              filter: _.map(filter.value.split('+'), (keywords) => ({
                bool: {
                  should: _.map(filter.fields, (field) => ({
                    terms: { [field]: keywords.split(',') }
                  }))
                }
              }))
            }
          }
        case 'searchPhrase':
          return {
            bool: {
              should: _.map(filter.value.split(','), (search) => ({
                match_phrase: { [field]: search }
              }))
            }
          }
        case 'gtlt':
          if (filter.value.operator && filter.value.value) {
            return {
              range: {
                [field]: {
                  [filter.value.operator]: filter.value.value
                }
              }
            }
          }
          break
        case 'minMax':
          var {
            min
          } = filter.value
          var {
            max
          } = filter.value
          if (min || max) {
            range = {}
            if (min) {
              range.gte = min
            }
            // if max
            //   range.lte = max
            return {
              range: {
                [field]: range
              }
            }
          }
          break
        case 'gtZero':
          return {
            range: {
              [field]: {
                gt: 0
              }
            }
          }
        case 'listAnd': case 'listBooleanAnd':
          return {
            bool: {
              must: _.filter(_.map(filter.value, (value, key) => {
                if (value && filter.queryFn) {
                  return filter.queryFn(value, key)
                } else if (value) {
                  return { match: { [`${field}.${key}`]: value } }
                }
              }))
            }
          }
        case 'listBooleanOr': case 'listOr':
          return {
            bool: {
              should: _.filter(_.map(filter.value, (value, key) => {
                if (value && filter.queryFn) {
                  return filter.queryFn(value, key)
                } else if (value) {
                  return { match: { [`${field}.${key}`]: value } }
                }
              }))
            }
          }
        case 'ntee':
          return {
            bool: {
              should:
                _.map(filter.value.nteeMajors, (value, key) => ({
                  match_phrase_prefix: { nteecc: key }
                })).concat(_.map(filter.value.ntees, (value, key) => ({
                  match: { nteecc: key }
                })))
            }
          }
        case 'fundedNtee':
          return {
            bool: {
              should:
                _.map(filter.value.nteeMajors, (value, key) => ({
                  nested: {
                    path: 'fundedNteeMajors',
                    query: {
                      bool: {
                        must: [
                          { match: { 'fundedNteeMajors.key': key } },
                          { range: { 'fundedNteeMajors.percent': { gte: 2 } } }
                        ]
                      }
                    }
                  }
                })).concat(_.map(filter.value.ntees, (value, key) => ({
                  nested: {
                    path: 'fundedNtees',
                    query: {
                      bool: {
                        must: [
                          { match: { 'fundedNtees.key': key } },
                          { range: { 'fundedNtees.percent': { gte: 2 } } }
                        ]
                      }
                    }
                  }
                })))
            }
          }
        case 'fieldList':
          return {
            bool: {
              should: _.filter(_.map(filter.value, (value, key) => {
                if (value) {
                  return { match: { [field]: key } }
                }
              })
              )
            }
          }
        case 'boolean':
          return {
            match: { [field]: true }
          }
        case 'booleanArray':
          var withValues = _.filter(fieldFilters, 'value')

          return {
            // there's potentially a cleaner way to do this?
            bool: {
              should: _.map(withValues, ({ value, arrayValue, valueFn }) => {
                // if subtypes are specified
                if (typeof value === 'object') {
                  return {
                    bool: {
                      must: [
                        { match: { [field]: arrayValue } }, {
                          bool: {
                            should: valueFn(value)
                          }
                        }
                      ]
                    }
                  }
                } else {
                  return { match: { [field]: arrayValue } }
                }
              })
            }

          }
      }
    }))

    return filter
  }
}

export default new SearchFiltersService()
