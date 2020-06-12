import SharedModel from 'frontend-shared/models/index'

// import Entity from './entity'
// import EntityUser from './entity_user'
import Experiment from './experiment'
import IrsContribution from './irs_contribution'
import IrsFund from './irs_fund'
import IrsFund990 from './irs_fund_990'
import IrsOrg from './irs_org'
import IrsOrg990 from './irs_org_990'
import IrsPerson from './irs_person'
// import Notification from './notification'
// import PushToken from './push_token'
// import Subscription from './subscription'
// import UserData from './user_data'
// import UserSettings from './user_settings'

export default class Model extends SharedModel {
  constructor () {
    super(...arguments)
    // TODO: rename entity to team or organization (organization might be confusing)
    // @entity = new Entity {@auth}
    // @entityUser = new EntityUser {@auth}
    this.experiment = new Experiment({ cookie: this.cookie })
    this.irsContribution = new IrsContribution({ auth: this.auth })
    this.irsFund = new IrsFund({ auth: this.auth })
    this.irsFund990 = new IrsFund990({ auth: this.auth })
    this.irsOrg = new IrsOrg({ auth: this.auth })
    this.irsOrg990 = new IrsOrg990({ auth: this.auth })
    this.irsPerson = new IrsPerson({ auth: this.auth })
  }
}
// @notification = new Notification {@auth}
// @pushToken = new PushToken {@auth, @token}
// @subscription = new Subscription {@auth}
// @userData = new UserData {@auth}
// @userSettings = new UserSettings {@auth}
