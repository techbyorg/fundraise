z = require 'zorium'
_capitalize = require 'lodash/capitalize'
_map = require 'lodash/map'
_filter = require 'lodash/filter'

config = require '../config'

class FormatService
  number: (number) ->
    # http://stackoverflow.com/a/2901298
    if number?
      Math.round(number).toString().replace(/\B(?=(\d{3})+(?!\d))/g, ',')
    else
      '...'
  # https://stackoverflow.com/a/10601315
  abbreviateNumber: (value) ->
    newValue = value
    if value >= 1000
      suffixes = [
        ''
        'k'
        'm'
        'b'
        't'
      ]
      suffixNum = Math.floor(('' + value).length / 3)
      shortValue = ''
      precision = 2
      while precision >= 1
        shortValue = parseFloat((if suffixNum != 0 then value / 1000 ** suffixNum else value).toPrecision(precision))
        dotLessShortValue = (shortValue + '').replace(/[^a-zA-Z 0-9]+/g, '')
        if dotLessShortValue.length <= 2
          break
        precision--
      if shortValue % 1 != 0
        shortValue = shortValue.toFixed(1)
      newValue = shortValue + suffixes[suffixNum]
    newValue

  location: (obj) ->
    {city, state} = obj or {}
    if city and state
      "#{city}, #{state}"
    else if state
      state
    else if obj
      'Unknown'
    else
      '...'

  fixAllCaps: (str) ->
    str?.toLowerCase().replace(/\w+/g, _capitalize)

  percentage: (value) ->
    "#{Math.round(value * 100)}%"

  centsToDollars: (cents) ->
    (cents / 100).toFixed(2)

  countdown: (s) ->
    seconds = Math.floor(s % 60)
    if seconds < 10
      seconds = "0#{seconds}"
    days = Math.floor(s / 86400)
    minutes = Math.floor(s / 60) % 60
    if minutes < 10
      minutes = "0#{minutes}"
    if days > 2
      hours = Math.floor(s / 3600) % 24
      if hours < 10
        hours = "0#{hours}"
      prettyTimer = "#{days} days"
    else
      hours = Math.floor(s / 3600)
      if hours < 10
        hours = "0#{hours}"
      prettyTimer = "#{hours}:#{minutes}:#{seconds}"

    return prettyTimer

  # https://stackoverflow.com/a/32638472
  shortNumber: (num, fixed) ->
    if num is null
      return null
    # terminate early
    if num is 0
      return '0'
    # terminate early
    fixed = if not fixed or fixed < 0 then 0 else fixed
    # number of decimal places to show
    b = num.toPrecision(2).split('e')
    k = if b.length == 1 then 0 else Math.floor(Math.min(b[1].slice(1), 14) / 3)
    c = if k < 1 then num.toFixed(0 + fixed) else (num / 10 ** (k * 3)).toFixed(1 + fixed)
    d = if c < 0 then c else Math.abs(c)
    e = d + [
      ''
      'K'
      'M'
      'B'
      'T'
    ][k]
    # append power
    e

module.exports = new FormatService()
