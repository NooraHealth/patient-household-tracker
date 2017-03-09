
moment  = require 'moment-timezone'

getDateTime = ( date, time, timezone )->
  stringified = if time then "#{date} #{time}" else "#{date}"
  return moment.tz( stringified , timezone).format()

getHour = ( time )-> if time then time.substr(0, 2) else 0
getMinute = ( time )-> if time then time.substr(3, 2) else 0

module.exports.getHour = getHour
module.exports.getMinute = getMinute
module.exports.getDateTime = getDateTime
