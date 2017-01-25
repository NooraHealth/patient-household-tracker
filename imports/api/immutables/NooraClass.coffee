
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
  errored_attendees: []
}

class NooraClass extends BaseNooraClass
  constructor: ( properties )->
    super Object.assign({}, properties, {
      attendees: Immutable.List properties && properties.attendees,
      educators: Immutable.List properties && properties.educators
    });

  save: ->
    nooraClass = this
    return new Promise ( resolve, reject )->
      Meteor.call "nooraClass.upsert", nooraClass.toJS(), ( error, results )->
        if error
          reject error
        else
          doc = Classes.findOne({ name: nooraClass.name })
          Meteor.call "syncWithSalesforce", doc
          resolve Classes.findOne { name: nooraClass.name }

if Meteor.isServer
  { SalesforceInterface } = require '../salesforce/SalesforceInterface.coffee'

  Meteor.methods
    "syncWithSalesforce": ( classDoc )->
      console.log "Syncing with salesforce"
      toSalesforce = new SalesforceInterface()
      if classDoc.attendance_report_salesforce_id != '' and classDoc.attendees.length > 0
        promise = toSalesforce.upsertAttendees(classDoc, classDoc.attendees)
        promise.then(( results )->
          console.log "Success exporting attendees"
          console.log "The errored attendees"
          console.log results
          console.log results.errored
          classDoc.attendees = results.successful
          classDoc.errored_attendees = results.errored
          Classes.update { name: classDoc.name }, {$set: classDoc }
          #TODO: make this clearer that this is to account for errors
          return toSalesforce.upsertAttendees(classDoc, results.errored)
        ).then(( results )->
          console.log "Attendees that were errored and now are not"
          console.log results
          classDoc.attendees = classDoc.attendees.concat results.successful
          classDoc.errored_attendees = results.errored
          classDoc.export_attendees_error = if results.errored.length > 0 then true else false
          Classes.update { name: classDoc.name }, {$set: classDoc }
        , ( err )->
          Classes.update { name: classDoc.name }, {$set: { export_attendees_error: true }}
          console.log "error exporting attendees"
          console.log err
        )
      else
        promise = toSalesforce.exportClass(classDoc);
        promise.then( (id)->
          console.log "Success exporting class!! "
          classDoc.attendance_report_salesforce_id = id
          Classes.update { name: classDoc.name }, {$set: classDoc }
          console.log classDoc.attendance_report_salesforce_id
          return toSalesforce.exportClassEducators(classDoc)
        ).then(( educators )->
          console.log "Success exporting class educator objects"
          classDoc.educators = educators
          classDoc.export_class_error = false
          Classes.update { name: classDoc.name }, {$set: classDoc }
          console.log Classes.findOne { name: classDoc.name }
        , (err)->
          console.log "There was an error syncing with salesforce"
          console.log err
          Classes.update { name: classDoc.name }, {$set: { export_class_error: true }}
        )
    setClassName: ->

    "nooraClass.upsert": ( nooraClass )->
      getClassName = (doc)->
        suffix = if doc.end_time then " to #{doc.end_time}" else ""
        return "#{ doc.facility_name }: #{ doc.location } - #{ doc.date }, #{doc.start_time}#{suffix}"

      if not nooraClass.date_created? or nooraClass.date_created is ''
        nooraClass.date_created = moment().toISOString()

      if not nooraClass.name? or nooraClass.name is ''
        nooraClass.name = getClassName(nooraClass)

      # nooraClass.attendees = nooraClass.attendees.forEach ( attendee )=>
      #   if not attendee.patient_id? or attendee.patient_id == ''
      #     attendee.patient_id = getNewPatientId(attendee)
      #   return attendee
      #
      facility = Facilities.findOne { name: nooraClass.facility_name }
      if not facility
        throw new Meteor.Error "Facility Does Not Exist", "That facility is not in the database. Ensure that the facility exists in Salesforce and has been synced with the app"
      nooraClass.facility_salesforce_id = facility.salesforce_id
      ClassesSchema.clean(nooraClass)
      ClassesSchema.validate(nooraClass);
      console.log "Saving this nooraClass"
      console.log nooraClass
      return Classes.upsert { name: nooraClass.name }, { $set: nooraClass }

module.exports.NooraClass = NooraClass
