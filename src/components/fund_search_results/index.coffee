{z} = require 'zorium'

$table = require '../table'
FormatService = require '../../services/format'

if window?
  require './index.styl'

module.exports = $fundSearchResults = ({model, rows}) ->
  z '.z-fund-search-results',
    z $table,
      data: rows
      onRowClick: (e, i) ->
        router.goFund rows[i]
      columns: [
        {key: 'name', name: 'Name', width: 240, isFlex: true}
        {
          key: 'assets', name: model.l.get('org.assets')
          width: 150
          content: ({row}) ->
            FormatService.abbreviateDollar row.assets
        }
        {
          key: 'grantMedian', name: model.l.get('fund.medianGrant')
          width: 170
          content: ({row}) ->
            FormatService.abbreviateDollar row.lastYearStats?.grantMedian
        }
        {
          key: 'grantSum', name: model.l.get('fund.grantsPerYear')
          width: 150
          content: ({row}) ->
            FormatService.abbreviateDollar row.lastYearStats?.grantSum
        }
      ]
