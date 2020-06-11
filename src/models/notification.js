// TODO: need to convert to graphql before this will work

let Notification;
export default Notification = (function() {
  Notification = class Notification {
    static initClass() {
      this.prototype.namespace = 'notifications';
  
      this.prototype.ICON_MAP = {
        social: 'friends',
        privateMessage: 'chat',
        channelMessage: 'chat',
        channelMention: 'chat'
      };
    }

    constructor({auth}) { this.getAll = this.getAll.bind(this);     this.getUnreadCount = this.getUnreadCount.bind(this);     this.auth = auth; null; }

    getAll() {
      return this.auth.stream(`${this.namespace}.getAll`, {});
    }

    getUnreadCount() {
      return this.auth.stream(`${this.namespace}.getUnreadCount`, {});
    }
  };
  Notification.initClass();
  return Notification;
})();
