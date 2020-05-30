import {z, useContext, useMemo, useStream} from 'zorium'
import * as _ from 'lodash-es'
import * as Rx from 'rxjs'
import * as rx from 'rxjs/operators'

import $button from 'frontend-shared/components/button'
import $input from 'frontend-shared/components/input'
import $table from 'frontend-shared/components/table'
import {searchIconPath} from 'frontend-shared/components/icon/paths'
import FormatService from 'frontend-shared/services/format'

#import  $irsSearch from '../irs_search'
import $filterBar from '../filter_bar'
import $fundSearchResults from '../fund_search_results'
import $searchInput from '../search_input'
import $searchTags from '../search_tags'
import SearchFiltersService from '../../services/search_filters'
import context from '../../context'

if window?
  require './index.styl'

export default $search = ({org}) ->
  {model, lang, cookie} = useContext context

  {filtersStream, nameStream, modeStream, searchResultsStream} = useMemo ->
    filtersStream = SearchFiltersService.getFiltersStream {
      cookie, filters: SearchFiltersService.getFundFilters(lang)
    }
    nameStream = new Rx.BehaviorSubject ''

    esQueryFilterStream = filtersStream.pipe rx.map (filters) ->
      SearchFiltersService.getESQueryFilterFromFilters(
        filters
      )

    esQueryFilterAndNameStream = Rx.combineLatest(
      esQueryFilterStream, nameStream, (vals...) -> vals
    )

    {
      filtersStream
      nameStream
      modeStream: new Rx.BehaviorSubject 'tags'
      searchResultsStream: esQueryFilterAndNameStream
      .pipe rx.switchMap ([esQueryFilter, name]) ->
        bool = {filter: esQueryFilter}
        if name
          bool.must =
            multi_match:
              query: name
              type: 'bool_prefix'
              fields: ['name', 'name._2gram', 'ein']

        model.irsFund.search {
          query:
            bool: bool

          limit: 10
        }
    }
  , []

  {mode, focusAreasFilter, statesFilter, searchResults} = useStream ->
    mode: modeStream
    focusAreasFilter: filtersStream.pipe rx.map (filters) ->
      _.find filters, {id: 'fundedNteeMajor'}
    statesFilter: filtersStream.pipe rx.map (filters) ->
      _.find filters, {id: 'state'}
    searchResults: searchResultsStream

  console.log searchResults

  z '.z-search',
    z '.search',
      z '.title', lang.get 'fundSearch.titleSpecific'
      z '.search-box',
        if mode is 'specific'
          z $searchInput,
            valueStream: nameStream
            placeholder: lang.get 'fundSearch.byNameEinPlaceholder'
        else
          [
            z $searchTags,
              filter: focusAreasFilter
              title: lang.get 'fund.focusAreas'
              placeholder: lang.get 'fundSearch.focusAreasPlaceholder'
            z '.divider'
            z $searchTags,
              filter: statesFilter
              title: lang.get 'general.location'
              placeholder: lang.get 'fundSearch.locationPlaceholder'
            z '.button',
              z $button,
                isPrimary: true
                icon: searchIconPath
                text: lang.get 'general.search'
          ]

      z '.alt', {
        onclick: ->
          if mode is 'specific'
            modeStream.next 'tags'
          else
            focusAreasFilter.valueStreams.next Rx.of null
            statesFilter.valueStreams.next Rx.of null
            modeStream.next 'specific'
      },
        z '.or', lang.get 'general.or'
        z '.text', lang.get 'fundSearch.byNameEin'

    z '.results',
      z '.title',
        lang.get 'fundSearch.resultsTitle', {
          replacements:
            count: FormatService.number searchResults?.totalCount
        }
      z '.filter-bar',
        z $filterBar, {filtersStream}

      z $fundSearchResults, {rows: searchResults?.nodes}


    # z '.title', 'Search foundations'
    # z '.input',
    #   z $irsSearch, {
    #     model, router, irsType: 'irsFund', hintText: 'Foundation name'
    #   }
    # z '.title', 'Search organizations'
    # z '.input',
    #   z $irsSearch, {
    #     model, router, irsType: 'irsOrg', hintText: 'Organization name'
    #   }
    # z '.title', 'Search people'
    # z '.input',
    #   z $irsSearch, {
    #     model, router, irsType: 'irsPerson', hintText: 'Person name'
    #   }
