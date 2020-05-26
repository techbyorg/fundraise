{z} = require 'zorium'
RxBehaviorSubject = require('rxjs/BehaviorSubject').BehaviorSubject
_map = require 'lodash/map'

$appBar = require '../../components/app_bar'
$search = require '../../components/search'
config = require '../../config'

if window?
  require './index.styl'

module.exports = $searchPage = ({entityStream}) ->
  z '.p-search',
    z $appBar, {
      hasLogo: true
      # $topLeftButton: z $buttonBack, {color: colors.$header500Icon}
    }
    z $search
