
module.exports.isInt = ( val )->
  return not isNaN( parseInt(val) )

module.exports.getRoleName = ( educator )->
  #TODO make these into collection heleprs
  firstName = if educator.first_name then educator.first_name else ""
  lastName = if educator.last_name then educator.last_name else ""
  return "Educator Trainee -- #{ firstName } #{ lastName }"

module.exports.getOperationRoleName = ( educator, role )->
  firstName = if educator.first_name then educator.first_name else ""
  lastName = if educator.last_name then educator.last_name else ""
  return "Nurse Educator #{ firstName } #{ lastName } at #{ educator.facility_name }"
