semverCompare = require 'semver-compare'
_padStart = require 'lodash/padStart'

ONE_MINUTE_S = 60
ONE_HOUR_S = 3600
ONE_DAY_S = 3600 * 24
ONE_WEEK_S = 3600 * 24 * 7

class DateService
  constructor: ->
    @setLocale 'en'

  setLang: (@lang) => null

  format: (date, format) ->
    unless date instanceof Date
      date = new Date date
    # TODO: only thing that uses this so far uses yyyy-mm-dd format and MMM Do
    if format is 'MMM D'
      MMM = @lang.get("months.#{date.getMonth()}").substring(0, 3)
      D = date.getDate()
      "#{MMM} #{D}"
    else if format is 'MMM D, h:mm a'
      MMM = @lang.get("months.#{date.getMonth()}").substring(0, 3)
      D = date.getDate()
      hours = date.getHours()
      h = hours % 12
      if h is 0
        h = 12
      mm = _padStart date.getMinutes(), 2, '0'
      a = if hours > 12 then 'pm' else 'am'
      "#{MMM} #{D}, #{h}:#{mm} #{a}"
    else if format is 'MMMM yyyy'
      MMMM = @lang.get("months.#{date.getMonth()}")
      yyyy = date.getFullYear()
      "#{MMMM} #{yyyy}"
    else if format is 'MMM yyyy'
      MMM = @lang.get("months.#{date.getMonth()}").substring(0, 3)
      yyyy = date.getFullYear()
      "#{MMM} #{yyyy}"
    else
      yyyy = date.getFullYear()
      mm = date.getMonth() + 1
      if mm < 10
        mm = "0#{mm}"
      dd = date.getDate()
      if dd < 10
        dd = "0#{dd}"
      "#{yyyy}-#{mm}-#{dd}"

  formatDuration: (duration) ->
    # https://stackoverflow.com/a/30134889
    match = duration.match(/PT(\d+H)?(\d+M)?(\d+S)?/)
    match = match.slice(1).map((x) ->
      return x?.replace(/\D/, '')
    )
    hours = _padStart parseInt(match[0]) or 0, 2, '0'
    minutes = _padStart parseInt(match[1]) or 0, 2, '0'
    seconds = _padStart parseInt(match[2]) or 0, 2, '0'
    if hours isnt '00'
      "#{hours}:#{minutes}:#{seconds}"
    else if minutes isnt '00'
      "#{minutes}:#{seconds}"
    else
      "00:#{seconds}"

  formatSeconds: (seconds, precision = 0) =>
    if seconds < ONE_MINUTE_S
      divisor = 1
      str = @lang.get 'time.secondShorthand'
    else if seconds < ONE_HOUR_S
      divisor = ONE_MINUTE_S
      str = @lang.get 'time.minuteShorthand'
    else if seconds <= ONE_DAY_S
      divisor = ONE_HOUR_S
      str = @lang.get 'time.hourShorthand'
    else if seconds <= ONE_WEEK_S
      divisor = ONE_DAY_S
      str = @lang.get 'time.dayShorthand'
    return +parseFloat(seconds / divisor).toFixed(precision) + str

  fromNowSeconds: (seconds) =>
    if isNaN seconds
      '...'
    else if seconds < 30
      @lang.get 'time.justNow'
    else if seconds < ONE_MINUTE_S
      return parseInt(seconds) + @lang.get 'time.secondShorthand'
    else if seconds < ONE_HOUR_S
      return parseInt(seconds / ONE_MINUTE_S) + @lang.get 'time.minuteShorthand'
    else if seconds <= ONE_DAY_S
      return parseInt(seconds / ONE_HOUR_S) + @lang.get 'time.hourShorthand'
    else if seconds <= ONE_WEEK_S
      return parseInt(seconds / ONE_DAY_S) + @lang.get 'time.dayShorthand'
    else
      return parseInt(seconds / ONE_WEEK_S) + @lang.get 'time.weekShorthand'

  fromNow: (date) =>
    unless date instanceof Date
      date = new Date date
    seconds = Math.abs (Date.now() - date.getTime()) / 1000
    @fromNowSeconds seconds

  setLocale: (locale) ->
    null
    # @langocaleFile = if window?
    #   window?.dateLocales?[locale]
    # else
    #   require("date-fns/locale/#{locale}")

  getLocalDateFromStr: (str) ->
    if str
      arr = str.split '-'
      new Date arr[0], arr[1] - 1, arr[2]
    else
      null

module.exports = new DateService()
