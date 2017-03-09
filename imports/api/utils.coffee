
moment  = require 'moment-timezone'

getDateTime = ( date, time, timezone )->
  console.log time
  stringified = if time then "#{date} #{time}" else "#{date}"
  console.log "Dat time str: " + stringified
  return moment.tz( stringified , timezone).format()

getHour = ( time )-> if time then time.substr(0, 2) else 0
getMinute = ( time )-> if time then time.substr(3, 2) else 0

module.exports.getHour = getHour
module.exports.getMinute = getMinute
module.exports.getDateTime = getDateTime
