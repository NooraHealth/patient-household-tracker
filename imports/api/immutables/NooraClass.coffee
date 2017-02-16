
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
  deleted_educators: Immutable.List(),
  facility_salesforce_id: '',
  condition_operation_salesforce_id: '',
  attendance_report_salesforce_id: '',
  facility_name: '',
  majority_language: '',
  attendees: Immutable.List(),
  deleted_attendees: Immutable.List(),
  errors: []
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
      # getClassName = ( doc )->
      #   suffix = if doc.end_time then " to #{doc.end_time}" else ""
      #   return "#{ doc.facility_name }: #{ doc.location } - #{ doc.date }, #{doc.start_time}#{suffix}"
      #
      # if not nooraClass.date_created? or nooraClass.date_created is ''
      #   nooraClass.date_created = moment().toISOString()
      #
      # # if not nooraClass.name? or nooraClass.name is ''
      # nooraClass.name = getClassName nooraClass
      # console.log "About to save this: "
      # console.log nooraClass

      Meteor.call "syncWithSalesforce", nooraClass, nooraClass.deleted_attendees, nooraClass.deleted_educators, ( error, results )->
        console.log "Returning from sync w salesforce"
        console.log results
        if error
          console.log "Error??"
          reject error
        else
          console.log "Promise"
          resolve( results )
          # promise.then((doc)->
          #   console.log "REsolving promis"
          #   resolve doc
          # , (err) ->
          #   console.log "Error"
          #   reject(err)
          # )

if Meteor.isServer
  { SalesforceInterface } = require '../salesforce/SalesforceInterface.coffee'

  Meteor.methods

    "syncWithSalesforce": ( classDoc, deletedAttendees, deletedEducators )->
      facility = Facilities.findOne { name: classDoc.facility_name }
      if not facility
        throw new Meteor.Error "Facility Does Not Exist", "That facility is not in the database. Ensure that the facility exists in Salesforce and has been synced with the app"

      classDoc.facility_salesforce_id = facility.salesforce_id
      classDoc.errors = []

      toSalesforce = new SalesforceInterface()
      promise = toSalesforce.upsertClass(classDoc)
      return promise.then( (results)->
        classDoc.attendance_report_salesforce_id = results.id
        console.log results.errors
        classDoc.errors = results?.errors or []
        ClassesSchema.clean(classDoc)
        console.log "ClassDoc!"
        console.log classDoc
        return Promise.resolve(ClassesSchema.validate(classDoc))
      ).then(()->
        id = classDoc.attendance_report_salesforce_id
        return Promise.resolve(Classes.upsert { attendance_report_salesforce_id: id }, { $set: classDoc })
      ).then(()->
        console.log "Trying second tier"
        return toSalesforce.exportClassEducators( classDoc.educators, classDoc.facility_salesforce_id, classDoc.attendance_report_salesforce_id )
      ).then(( results )->
        console.log "Success exporting class educator objects"
        classDoc.educators = results.educators
        id = classDoc.attendance_report_salesforce_id
        if results.errors
          classDoc.errors = classDoc.errors.concat results.errors
        Classes.update { attendance_report_salesforce_id: id }, { $set: classDoc }
        filtered = deletedEducators.filter (educator)->
          id = educator.class_educator_salesforce_id
          return id? and id != ''
        toDelete = filtered.map (educator) -> return educator.class_educator_salesforce_id
        newPromise =  toSalesforce.deleteRecords(toDelete, "Class_Educator__c")
        return newPromise
      ).then(( deleteResults )->
        console.log "Success deleting class educator objects"
        if deleteResults.errors
          classDoc.errors = classDoc.errors.concat deleteResults.errors
        return toSalesforce.upsertAttendees(classDoc, classDoc.attendees)
      ).then( (results)->
        console.log "Successfully upserted Attendees"
        console.log "results.attendees"
        console.log results.attendees
        classDoc.attendees = results.attendees
        id = classDoc.attendance_report_salesforce_id
        if results.errors
          classDoc.errors = classDoc.errors.concat results.errors
        Classes.update { attendance_report_salesforce_id: id }, { $set: classDoc }
        filtered = deletedAttendees.filter (attendee)->
          id = attendee.contact_salesforce_id
          return id? and id != ''
        toDelete = filtered.map (attendee) -> return attendee.contact_salesforce_id
        return toSalesforce.deleteRecords(toDelete, "Contact")
      ).then( (results)->
        console.log "Successfully deleted attendees"
        if results.errors
          classDoc.errors = classDoc.errors.concat results.errors
        return { doc: classDoc, syncErrors: classDoc.errors }
      , (err)->
        console.log err
        throw err
      )

    "nooraClass.upsert": ( nooraClass )->

      facility = Facilities.findOne { name: nooraClass.facility_name }
      if not facility
        throw new Meteor.Error "Facility Does Not Exist", "That facility is not in the database. Ensure that the facility exists in Salesforce and has been synced with the app"

      nooraClass.facility_salesforce_id = facility.salesforce_id
      ClassesSchema.clean(nooraClass)
      ClassesSchema.validate(nooraClass);
      reportId = nooraClass.attendance_report_salesforce_id
      return Classes.upsert { attendance_report_salesforce_id: reportId }, { $set: nooraClass }

module.exports.NooraClass = NooraClass
