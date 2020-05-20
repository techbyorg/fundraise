{z, useMemo, useStream} = require 'zorium'

if window?
  require './index.styl'

module.exports = Fund = ({model, router, irsFundStream}) ->
  {contributionsStream, personsStream} = useMemo ->
    {
      contributionsStream: irsFundStream.switchMap (irsFund) ->
        model.irsContribution.getAllByFromEin irsFund.ein
      personsStream: irsFundStream.switchMap (irsFund) ->
        model.irsPerson.getAllByEin irsFund.ein
    }
  , []

  {contributions, persons} = useStream ->
    contributions: contributionsStream
    persons: personsStream

  console.log 'c', contributions, 'persons', persons

  z '.z-fund',
    'fund!'
