z = require 'zorium'
# TODO: webpack chunk import
Chartist = if window? then require 'chartist' else null

colors = require '../../colors'

if window?
  require './index.styl'

module.exports = class Graph
  type: 'Widget'

  constructor: ->
    @labels = []
    @series = []
    @options = {}

  afterMount: (@$$el) =>
    console.log 'mount'
    console.log '=================================='
    console.log '=================================='
    console.log '=================================='
    console.log '=================================='
    @chart = new Chartist.Line @$$el, {@labels, @series}, @options
    # allow for gradient
    @chart.on 'created', (ctx) ->
      document.getElementsByClassName('ct-chart-line')?[0]?.setAttribute('style', 'overflow: visible !important;')
      defs = ctx.svg.elem('defs')
      defs.elem('linearGradient',
        id: 'gradient'
        x1: 0
        y1: 1
        x2: 0
        y2: 0
      ).elem('stop',
        offset: 0
        'stop-color': colors.$secondaryMain
        'stop-opacity': 0
      ).parent()
      .elem 'stop',
        offset: 1
        'stop-color': colors.$secondaryMain

  beforeUnmount: =>
    @chart?.detach()

  getChartist: ->
    Chartist

  render: ({@labels, @series, @options}) =>
    console.log 'update', {@labels, @series}, @options
    @chart?.update {@labels, @series}, @options
    z '.z-graph-widget', {key: 'graph-widget'}
