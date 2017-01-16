
moment   = require 'moment'

getDateTime = ( date, time )->
  return moment(date)
    .add(getHour(time), "hours")
    .add(getMinute(time), "minutes")
    .toISOString()

getHour = ( time )-> if time then time.substr(0, 2) else 0
getMinute = ( time )-> if time then time.substr(3, 2) else 0

module.exports.getHour = getHour
module.exports.getMinute = getMinute
module.exports.getDateTime = getDateTime
