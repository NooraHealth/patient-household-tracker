
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
    console.log moment
    super Object.assign({}, properties, {
      attendees: Immutable.List properties && properties.condition_operations
    });

  setClassName: ->
    return this.set "name", "#{ this.facility_name }: #{ this.location } - #{ this.date }, #{this.start_time} to #{this.end_time}"

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
          console.log nooraClass.name
          nooraClassDoc = Classes.findOne({ name: nooraClass.name })
          console.log "The doc"
          console.log nooraClassDoc
          console.log Classes.find({}).fetch()
          Meteor.call "syncWithSalesforce", nooraClassDoc
          resolve nooraClass

if Meteor.isServer
  { SalesforceInterface } = require '../salesforce/SalesforceInterface.coffee'

  Meteor.methods
    "syncWithSalesforce": ( classDoc )->
      console.log classDoc
      console.log "THIS IS WHERE YOU EXPORT TO SALESFORCE"
      toSalesforce = new SalesforceInterface()
      promise = toSalesforce.exportClass(classDoc);
      promise.then( (id)->
        console.log "Success exporting!! "
        console.log id
      , (err)->
        console.log "There was an error syncing with salesforce"
        console.log err
      )

    "nooraClass.upsert": ( nooraClass )->
      facility = Facilities.findOne { name: nooraClass.facility_name }
      if not facility
        throw new Meteor.Error "Facility Does Not Exist", "That facility is not in the database. Ensure that the facility exists in Salesforce and has been synced with the app"
      nooraClass.facility_salesforce_id = facility.salesforce_id
      ClassesSchema.clean(nooraClass)
      ClassesSchema.validate(nooraClass);
      return Classes.upsert { name: nooraClass.name }, { $set: nooraClass }

module.exports.NooraClass = NooraClass
