// https://github.com/jashkenas/coffeescript/issues/4769#issuecomment-420368833
require('module').prototype.options = {
  transpile: require('./babel.config')
};
require('coffeescript/register');
