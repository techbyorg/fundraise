var colors = require('./colors').default;

module.exports = function() {
  return function(style) {
    var nodes = this.nodes;
    return style.define('getColor', function(color) {
      return new nodes.Literal(colors[color.val] || 'transparent');
    });
  };
};
