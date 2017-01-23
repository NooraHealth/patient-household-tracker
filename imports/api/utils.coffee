
moment  = require 'moment-timezone'

getDateTime = ( date, time, timezone )->
  console.log "Getting the regular old moment"
  console.log timezone
  console.log "THAT WAS THE ICO"
  console.log "#{date} #{time}"
  return moment.tz("#{date} #{time}", timezone).format()
  # return moment(date)
  #   .add(getHour(time), "hours")
  #   .add(getMinute(time), "minutes")
  #   .toISOString()

getHour = ( time )-> if time then time.substr(0, 2) else 0
getMinute = ( time )-> if time then time.substr(3, 2) else 0

module.exports.getHour = getHour
module.exports.getMinute = getMinute
module.exports.getDateTime = getDateTime
