SharedModel = require 'frontend-shared/models/index'

Entity = require './entity'
EntityUser = require './entity_user'
Experiment = require './experiment'
IrsContribution = require './irs_contribution'
IrsFund = require './irs_fund'
IrsFund990 = require './irs_fund_990'
IrsOrg = require './irs_org'
IrsOrg990 = require './irs_org_990'
IrsPerson = require './irs_person'
Notification = require './notification'
PushToken = require './push_token'
Subscription = require './subscription'
UserData = require './user_data'
UserSettings = require './user_settings'

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
