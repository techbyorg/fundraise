{z} = require 'zorium'

if window?
  require './index.styl'

module.exports = $searchTags = ({title, placeholder}) ->
  z '.z-search-tags',
    z '.title', title
    z '.tags', placeholder
