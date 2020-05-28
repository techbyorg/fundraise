import config from '../config'

export default class IrsPerson
  constructor: ({@auth}) -> null

  getAllByEin: (ein) =>
    @auth.stream
      query: '''
        query IrsPersonGetAllByEin($ein: String!) {
          irsPersons(ein: $ein) {
            nodes { name, years { title, compensation, year } }
          }
        }
      '''
      variables: {ein}
      pull: 'irsPersons'
    , {ignoreCache: true}


  search: ({query, limit}) =>
    @auth.stream
      query: '''
        query IrsPersonSearch($query: JSON!) {
          irsPersons(query: $query) {
            nodes {
              name
            }
          }
        }
      '''
      variables: {query}
      pull: 'irsPersons'
    , {ignoreCache: true}
