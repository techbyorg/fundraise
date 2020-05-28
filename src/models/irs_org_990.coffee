import config from '../config'

export default class IrsOrg990
  constructor: ({@auth}) -> null

  getAllByEin: (ein) =>
    @auth.stream "#{@namespace}.getAllByEin", {ein}

  getStatsByEin: (ein) =>
    @auth.stream "#{@namespace}.getStatsByEin", {ein}
