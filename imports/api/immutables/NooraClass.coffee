
Immutable = require 'immutable'
moment = require 'moment'
{ Facilities } = require '../collections/facilities.coffee'
{ Classes } = require '../collections/classes.coffee'
{ ClassesSchema } = require '../collections/classes.coffee'

BaseNooraClass = Immutable.Record {
  location: '',
  name: '',
  date: moment().format("YYYY-MM-DD"),
  start_time: null,
  end_time: null,
  total_patients: 0,
  total_family_members: 0,
  educators: [],
  facility_salesforce_id: '',
  condition_operation_salesforce_id: '',
  record_salesforce_id: '',
  facility_name: '',
  attendees: Immutable.List()
}

class NooraClass extends BaseNooraClass
  constructor: ( properties )->
    super Object.assign({}, properties, {
      attendees: Immutable.List properties && properties.condition_operations
    });

  setClassName: ->
    return this.set "name", "#{ this.facility_name }: #{ this.location } - #{ this.date }  "

  save: ->
    nooraClass = this
    if nooraClass.name == ''
      nooraClass = nooraClass.setClassName()
    console.log "TO JS"
    console.log nooraClass.toJS()
    return new Promise ( resolve, reject )->
      Meteor.call "nooraClass.upsert", nooraClass.toJS(), ( error, results )->
        if error
          reject error
        else
          nooraClassDoc = Classes.findOne { _id: results._id }
          console.log "This is the nooraClassDoc"
          console.log nooraClassDoc
          Meteor.call "syncWithSalesforce", nooraClassDoc
          resolve nooraClass

if Meteor.isServer
  { SalesforceInterface } = require '../salesforce/SalesforceInterface.coffee'

  Meteor.methods
    "syncWithSalesforce": ( classDoc )->
      console.log classDoc
      console.log "THIS IS WHERE YOU EXPORT TO SALESFORCE"

    "nooraClass.upsert": ( nooraClass )->
      console.log "Saving this nooraClass"
      facility = Facilities.findOne { name: nooraClass.facility_name }
      if not facility
        throw new Meteor.Error "Facility Does Not Exist", "That facility is not in the database. Ensure that the facility exists in Salesforce and has been synced with the app"
      nooraClass.facility_salesforce_id = facility.salesforce_id
      ClassesSchema.clean(nooraClass)
      ClassesSchema.validate(nooraClass);
      console.log nooraClass
      return Classes.upsert { name: nooraClass.name }, { $set: nooraClass }

module.exports.NooraClass = NooraClass
