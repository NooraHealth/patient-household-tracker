
class AppConfig
  @get: ->
    @privateApp ?= new PrivateClass()
    return @privateApp

  class PrivateClass
    constructor: ->

    setFacilityName: ( name )->
      Session.set "current_facility_name", name

    getSupportedLanguages: ->
      return ['English', 'Kannada', 'Hindi', 'Telugu',
      'Bengali', 'Tamil', 'Malayalam', 'Odiya', 'Konkani', 'Marathi'];

    getBaseDiagnoses: ->
      return ["CABG", "VSD (ventricular septal defect)",
        "ASD (atrial septal defect)", "ICR" , "OP-CABG", "MVR",
        "AVR", "SSI/sternal wound infection", "MVR and TVR",
        "DVR", "PVD", "IHD (ischemic heart disease)", "RHD",
        "ACS (acute coronary syndrome)", "ILR (implantable loop recorder)",
        "TVD (tricuspid valve disease)", "PTCA", "Angiography", "Angioplasty",
        "COPD", "HTN", "DM", "fever", "cancer"]

    getFacilityName: ->
      name = Session.get "current_facility_name"
      if name == undefined
        @setFacilityName ""
      Session.get "current_facility_name"


module.exports.AppConfig = AppConfig.get()
