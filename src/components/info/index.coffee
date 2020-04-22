z = require 'zorium'
_defaults = require 'lodash/defaults'
_snakeCase = require 'lodash/snakeCase'

Base = require '../base'
Icon = require '../icon'
Spinner = require '../spinner'
FormattedText = require '../formatted_text'
DateService = require '../../services/date'
colors = require '../../colors'
config = require '../../config'

if window?
  require './index.styl'

module.exports = class EntityInfo extends Base
  constructor: ({@model, @router, @entity}) ->
    super()

    me = @model.user.getMe()

    @$datesIcon = new Icon()
    @$locationIcon = new Icon()
    @$priceIcon = new Icon()
    @$webIcon = new Icon()

    @$spinner = new Spinner()

    @$details = new FormattedText {
      text: @entity.map (entity) -> entity?.details
      imageWidth: 'auto'
      isFullWidth: true
      embedVideos: false
      @model
      @router
    }

    @state = z.state {
      entity: @entity.map (entity) ->
        _defaults {
          startTime: DateService.format new Date(entity?.startTime), 'MMM D'
          endTime: DateService.format new Date(entity?.endTime), 'MMM D'
        }, entity
    }

  getCoverUrl: (entity) =>
    # @model.image.getSrcByPrefix(
    #   place.attachmentsPreview.first.prefix, {size: 'large'}
    # )
    "#{config.CDN_URL}/entities/#{_snakeCase(entity.slug)}.jpg"

  render: =>
    {entity} = @state.getValue()

    price = if entity?.prices?.all is 0 \
            then 'Free' \
            else if entity?.prices?.all \
            then "$#{entity?.prices?.all}" \
            else @model.l.get 'general.unknown'

    z '.z-entity-info', {
      className: z.classKebab {@isImageLoaded}
    },
      if not entity?.slug
        z @$spinner
      else [
        z '.cover', {
          style:
            backgroundImage:
              "url(#{@getCoverUrl(entity)})"
        }
        z '.g-grid',
          z '.name', entity?.name
          z '.info',
            z '.section.dates',
              z '.icon',
                z @$datesIcon,
                  icon: 'clock'
                  isTouchTarget: false
                  color: colors.$primaryMain
              z '.text',
                "#{entity?.startTime} - #{entity?.endTime}"

          z '.title', @model.l.get 'place.details'
          z '.details', @$details
      ]
