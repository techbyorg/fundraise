{z} = require 'zorium'

if window?
  require './index.styl'

module.exports = SearchTags = ({title}) ->
  z '.z-search-tags',
    z '.title', title
