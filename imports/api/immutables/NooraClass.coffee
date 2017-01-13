
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
  facility_salesforce_id: '',
  record_salesforce_id: '',
  facility_name: ''
}

class NooraClass extends BaseNooraClass
  constructor: ( properties )->
    super Object.assign({}, properties);

  setClassName: ->
    console.log "Setting class name"
    return this.set "name", "#{ this.facility_name }: #{ this.location } - #{ this.date }  "

  save: ->
    nooraClass = this
    nooraClass = nooraClass.setClassName()
    nooraClass = nooraClass.set "start_time", nooraClass.start_time.format("HH:mm")
    nooraClass = nooraClass.set "end_time", nooraClass.end_time.format("HH:mm")
    console.log nooraClass.toJS()
    return new Promise ( resolve, reject )->
      Meteor.call "nooraClass.insert", nooraClass.toJS(), ( error, results )->
        if error
          reject error
        else
          console.log results
          console.log Classes.find({}).fetch()
          nooraClassDoc = Classes.findOne { _id: results._id }
          Meteor.call "syncWithSalesforce", nooraClassDoc
          resolve nooraClass

if Meteor.isServer
  { SalesforceInterface } = require '../salesforce/SalesforceInterface.coffee'

  Meteor.methods
    "syncWithSalesforce": ( nooraClass )->
      console.log nooraClass
      console.log "THIS IS WHERE YOU EXPORT TO SALESFORCE"

    "nooraClass.insert": ( nooraClass )->
      console.log "Saving this nooraClass"
      facility = Facilities.findOne { name: nooraClass.facility_name }
      if not facility
        throw new Meteor.Error "Facility Does Not Exist", "That facility is not in the database. Ensure that the facility exists in Salesforce and has been synced with the app"
      nooraClass.facility_salesforce_id = facility.salesforce_id
      ClassesSchema.clean(nooraClass)
      ClassesSchema.validate(nooraClass);
      return Classes.insert nooraClass

module.exports.NooraClass = NooraClass
