
Immutable = require 'immutable'
moment = require 'moment'
{ Facilities } = require '../collections/facilities.coffee'
{ Classes } = require '../collections/classes.coffee'
{ UniqueID } = require '../collections/unique_id.coffee'
{ ClassesSchema } = require '../collections/classes.coffee'

BaseNooraClass = Immutable.Record {
  location: '',
  name: '',
  date: moment().format("YYYY-MM-DD"),
  date_created: null,
  start_time: null,
  end_time: null,
  total_patients: 0,
  total_family_members: 0,
  educators: Immutable.List(),
  facility_salesforce_id: '',
  condition_operation_salesforce_id: '',
  attendance_report_salesforce_id: '',
  facility_name: '',
  majority_language: '',
  attendees: Immutable.List(),
  deleted_attendees: Immutable.List()
}

class NooraClass extends BaseNooraClass
  constructor: ( properties )->
    super Object.assign({}, properties, {
      attendees: Immutable.List properties && properties.attendees
    }, {
      educators: Immutable.List properties && properties.educators
    });

  save: ->
    nooraClass = this.toJS()
    return new Promise ( resolve, reject )->
      getClassName = ( doc )->
        suffix = if doc.end_time then " to #{doc.end_time}" else ""
        return "#{ doc.facility_name }: #{ doc.location } - #{ doc.date }, #{doc.start_time}#{suffix}"

      if not nooraClass.date_created? or nooraClass.date_created is ''
        nooraClass.date_created = moment().toISOString()

      if not nooraClass.name? or nooraClass.name is ''
        nooraClass.name = getClassName nooraClass
        if Classes.findOne({ name: nooraClass.name })
          reject "This class already exists in our database"
          return

      Meteor.call "nooraClass.upsert", nooraClass, ( error, results )->
        if error
          reject error
        else
          console.log "The results"
          console.log results
          doc = Classes.findOne({ name: nooraClass.name })
          Meteor.call "syncWithSalesforce", doc, nooraClass.attendees, nooraClass.deleted_attendees
          resolve doc

if Meteor.isServer
  { SalesforceInterface } = require '../salesforce/SalesforceInterface.coffee'

  Meteor.methods

    "syncWithSalesforce": ( classDoc, attendees, deletedAttendees )->
      toSalesforce = new SalesforceInterface()
      promise = toSalesforce.exportClass(classDoc)
      promise.then( (id)->
        console.log "Success exporting class!! "
        classDoc.attendance_report_salesforce_id = id
        Classes.update { name: classDoc.name }, { $set: classDoc }
        return toSalesforce.exportClassEducators( classDoc )
      ).then(( educators )->
        console.log "Success exporting class educator objects"
        classDoc.educators = educators
        classDoc.export_class_error = false
        Classes.update { name: classDoc.name }, {$set: classDoc }
        return toSalesforce.upsertAttendees(classDoc, attendees)
      ).then( (attendees)->
        console.log "Upserted attendees that were errored and now are not"
        classDoc.attendees = attendees
        Classes.update { name: classDoc.name }, {$set: classDoc }
        return toSalesforce.deleteAttendees(deletedAttendees)
      ).then( (results)->
        console.log "Successfully deleted attendees"
        console.log results
      , (err)->
        console.log "There was an error syncing with salesforce"
        console.log err
        Classes.update { name: classDoc.name }, {$set: { export_class_error: true }}
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
