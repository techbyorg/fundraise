// TODO: This file was created by bulk-decaffeinate.
// Sanity-check the conversion and remove this comment.
let EntityUser;
import * as _ from 'lodash-es';

import config from '../config';

// TODO: need to convert to graphql before this will work

export default EntityUser = (function() {
  EntityUser = class EntityUser {
    static initClass() {
      this.prototype.namespace = 'entityUsers';
    }

    constructor({auth}) { this.addRoleByEntityIdAndUserId = this.addRoleByEntityIdAndUserId.bind(this);     this.removeRoleByEntityIdAndUserId = this.removeRoleByEntityIdAndUserId.bind(this);     this.getByEntityIdAndUserId = this.getByEntityIdAndUserId.bind(this);     this.getTopByEntityId = this.getTopByEntityId.bind(this);     this.getMeSettingsByEntityId = this.getMeSettingsByEntityId.bind(this);     this.getOnlineCountByEntityId = this.getOnlineCountByEntityId.bind(this);     this.updateMeSettingsByEntityId = this.updateMeSettingsByEntityId.bind(this);     this.updateMeSettingsByEntityIdAndChannelId = this.updateMeSettingsByEntityIdAndChannelId.bind(this);     this.auth = auth; null; }

    addRoleByEntityIdAndUserId(entityId, userId, roleId) {
      return this.auth.call(`${this.namespace}.addRoleByEntityIdAndUserId`, {
        userId, entityId, roleId
      }, {invalidateAll: true});
    }

    removeRoleByEntityIdAndUserId(entityId, userId, roleId) {
      return this.auth.call(`${this.namespace}.removeRoleByEntityIdAndUserId`, {
        userId, entityId, roleId
      }, {invalidateAll: true});
    }

    getByEntityIdAndUserId(entityId, userId) {
      return this.auth.stream(`${this.namespace}.getByEntityIdAndUserId`, {entityId, userId});
    }

    getTopByEntityId(entityId) {
      return this.auth.stream(`${this.namespace}.getTopByEntityId`, {entityId});
    }

    getMeSettingsByEntityId(entityId) {
      return this.auth.stream(`${this.namespace}.getMeSettingsByEntityId`, {entityId});
    }

    getOnlineCountByEntityId(entityId) {
      return this.auth.stream(`${this.namespace}.getOnlineCountByEntityId`, {entityId});
    }

    updateMeSettingsByEntityId(entityId, {globalNotifications}) {
      return this.auth.call(`${this.namespace}.updateMeSettingsByEntityId`, {
        entityId, globalNotifications
      }, {invalidateAll: true});
    }

    updateMeSettingsByEntityIdAndChannelId({entityId, channelId, diff}) {
      return this.auth.call(`${this.namespace}.updateMeSettingsByEntityIdAndChannelId`, {
        entityId, channelId, diff
      }, {invalidateAll: true});
    }

    hasPermission({meEntityUser, me, permissions, channelId, roles}) {
      if (roles == null) { roles = meEntityUser?.roles; }
      const isGlobalModerator = me?.flags?.isModerator || (me?.email === 'austinhallock@gmail.com');
      return isGlobalModerator || _.every(permissions, permission => _.find(roles, function(role) {
        const channelPermissions = channelId && role.channelPermissions?.[channelId];
        const {
          globalPermissions
        } = role;
        permissions = _.defaults(
          channelPermissions, globalPermissions, config.DEFAULT_PERMISSIONS
        );
        return permissions[permission];
    }));
    }
  };
  EntityUser.initClass();
  return EntityUser;
})();
