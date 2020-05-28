import config from '../config'

export default class IrsFund990
  constructor: ({@auth}) -> null

  getAllByEin: (ein) ->
    @auth.stream
      query: '''
        query IrsFund990GetAllByEin($ein: String!) {
          irsFund990s(ein: $ein) {
            nodes { ein, year, taxPeriod }
          }
        }
      '''
      variables: {ein}
      pull: 'irsFund990s'
