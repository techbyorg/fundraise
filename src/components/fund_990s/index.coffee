{z, useMemo, useStream} = require 'zorium'
_map = require 'lodash/map'

$icon = require '../icon'
colors = require '../../colors'

if window?
  require './index.styl'

module.exports = $fund990s = ({model, router, irsFundStream}) ->
  {irsFund990sStream} = useMemo ->
    {
      irsFund990sStream: irsFundStream.switchMap (irsFund) ->
        model.irsFund990.getAllByEin irsFund.ein
    }
  , []

  {irsFund, irsFund990s} = useStream ->
    irsFund: irsFundStream
    irsFund990s: irsFund990sStream

  z '.z-fund-990s',
    z '.title', model.l.get 'fund990s.title'
    z '.irs-990s',
      _map irsFund990s?.nodes, ({ein, year, taxPeriod}, i) ->
        folder1 = ein.substr 0, 3
        if taxPeriod # TODO: rm when all loadAllYears reprocessed
          router.link z 'a.irs-990', {
            # TODO: https://www.irs.gov/charities-non-profits/tax-exempt-organization-search-bulk-data-downloads
            href: 'http://990s.foundationcenter.org/990pf_pdf_archive/' +
                  "#{folder1}/#{ein}/#{ein}_#{taxPeriod}_990PF.pdf"
          },
            z '.icon',
              z $icon,
                icon: 'pdf'
                isTouchTarget: false
                color: colors.$red500
            if i is 0
              "#{year} #{model.l.get 'fund990s.latestFiling'}"
            else
              "#{year}"