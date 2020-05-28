import SharedModel from 'frontend-shared/models/index'

import Entity from './entity'
import EntityUser from './entity_user'
import Experiment from './experiment'
import IrsContribution from './irs_contribution'
import IrsFund from './irs_fund'
import IrsFund990 from './irs_fund_990'
import IrsOrg from './irs_org'
import IrsOrg990 from './irs_org_990'
import IrsPerson from './irs_person'
import Notification from './notification'
import PushToken from './push_token'
import Subscription from './subscription'
import UserData from './user_data'
import UserSettings from './user_settings'

module.exports = class Model extends SharedModel
  constructor: ->
    super arguments...
    @entity = new Entity {@auth}
    @entityUser = new EntityUser {@auth}
    @experiment = new Experiment {@cookie}
    @irsContribution = new IrsContribution {@auth}
    @irsFund = new IrsFund {@auth}
    @irsFund990 = new IrsFund990 {@auth}
    @irsOrg = new IrsOrg {@auth}
    @irsOrg990 = new IrsOrg990 {@auth}
    @irsPerson = new IrsPerson {@auth}
    @notification = new Notification {@auth}
    @pushToken = new PushToken {@auth, @token}
    @subscription = new Subscription {@auth}
    @userData = new UserData {@auth}
    @userSettings = new UserSettings {@auth}
