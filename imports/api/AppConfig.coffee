
class AppConfig
  @get: ->
    @privateApp ?= new PrivateClass()
    return @privateApp

  class PrivateClass
    constructor: ->

    setFacilityName: ( name )->
      Session.set "current_facility_name", name

    getSupportedLanguages: ->
      return ['English', 'Kannada', 'Hindi', 'Telugu'];

    getFacilityName: ->
      name = Session.get "current_facility_name"
      if name == undefined
        @setFacilityName ""
      Session.get "current_facility_name"


module.exports.AppConfig = AppConfig.get()
