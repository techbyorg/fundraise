config = require '../config'

module.exports = class IrsOrg990
  namespace: 'irsOrg990s'

  constructor: ({@auth}) -> null

  getAllByEin: (ein) =>
    @auth.stream "#{@namespace}.getAllByEin", {ein}

  getStatsByEin: (ein) =>
    @auth.stream "#{@namespace}.getStatsByEin", {ein}
