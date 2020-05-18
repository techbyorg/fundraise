config = require '../config'

module.exports = class IrsFund990
  namespace: 'irsFund990s'

  constructor: ({@auth}) -> null

  getStatsByEin: (ein) =>
    @auth.stream "#{@namespace}.getStatsByEin", {ein}
