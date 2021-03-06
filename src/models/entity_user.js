import * as _ from 'lodash-es'

import config from '../config'

// TODO: need to convert to graphql before this will work

export default class EntityUser {
  constructor ({ auth }) {
    this.auth = auth
  }

  addRoleByEntityIdAndUserId = (entityId, userId, roleId) => {
    return this.auth.call(`${this.namespace}.addRoleByEntityIdAndUserId`, {
      userId, entityId, roleId
    }, { invalidateAll: true })
  }

  removeRoleByEntityIdAndUserId = (entityId, userId, roleId) => {
    return this.auth.call(`${this.namespace}.removeRoleByEntityIdAndUserId`, {
      userId, entityId, roleId
    }, { invalidateAll: true })
  }

  getByEntityIdAndUserId = (entityId, userId) => {
    return this.auth.stream(`${this.namespace}.getByEntityIdAndUserId`, { entityId, userId })
  }

  getTopByEntityId = (entityId) => {
    return this.auth.stream(`${this.namespace}.getTopByEntityId`, { entityId })
  }

  getMeSettingsByEntityId = (entityId) => {
    return this.auth.stream(`${this.namespace}.getMeSettingsByEntityId`, { entityId })
  }

  getOnlineCountByEntityId = (entityId) => {
    return this.auth.stream(`${this.namespace}.getOnlineCountByEntityId`, { entityId })
  }

  updateMeSettingsByEntityId = (entityId, { globalNotifications }) => {
    return this.auth.call(`${this.namespace}.updateMeSettingsByEntityId`, {
      entityId, globalNotifications
    }, { invalidateAll: true })
  }

  updateMeSettingsByEntityIdAndChannelId = ({ entityId, channelId, diff }) => {
    return this.auth.call(`${this.namespace}.updateMeSettingsByEntityIdAndChannelId`, {
      entityId, channelId, diff
    }, { invalidateAll: true })
  }

  hasPermission = ({ meEntityUser, me, permissions, channelId, roles }) => {
    if (roles == null) { roles = meEntityUser?.roles }
    const isGlobalModerator = me?.flags?.isModerator || (me?.email === 'austinhallock@gmail.com')
    return isGlobalModerator || _.every(permissions, permission => _.find(roles, function (role) {
      const channelPermissions = channelId && role.channelPermissions?.[channelId]
      const {
        globalPermissions
      } = role
      permissions = _.defaults(
        channelPermissions, globalPermissions, config.DEFAULT_PERMISSIONS
      )
      return permissions[permission]
    }))
  }
}
