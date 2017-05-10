
Immutable = require 'immutable'
moment = require 'moment'
{ Facilities } = require '../collections/facilities.coffee'
{ Classes } = require '../collections/classes.coffee'
{ UniqueID } = require '../collections/unique_id.coffee'
{ ClassesSchema } = require '../collections/classes.coffee'

BaseNooraClass = Immutable.Record {
  _id: null,
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
    docId = this._id
    nooraClass = this.toJS()
    deletedEducators = nooraClass.deleted_educators
    deletedAttendees = nooraClass.deleted_attendees
    return new Promise ( resolve, reject )->
      try
        ClassesSchema.clean(nooraClass)
        ClassesSchema.validate(nooraClass)
        if Classes.findOne({ name: nooraClass.name})? and not docId?
          reject { message: "Class #{ nooraClass.name } already exists. Please edit class from the home page." }
          return
      catch error
        reject( error )
        return

      #after clean/validation, return the _id to the document
      nooraClass._id = docId
      Meteor.call "syncWithSalesforce", nooraClass, deletedAttendees, deletedEducators, ( error, results )->
        if error
          reject error
        else
          resolve( results )

if Meteor.isServer

  { SalesforceInterface } = require '../salesforce/SalesforceInterface.coffee'

  Meteor.methods
    "syncWithSalesforce": ( classDoc, deletedAttendees, deletedEducators )->
      console.log "About to sync class "
      console.log classDoc
      toSalesforce = new SalesforceInterface()
      promise = Promise.resolve( Meteor.call "assignPatientIds", classDoc)
      return promise.then( (updatedClassDoc) ->
        #Upsert the class in Salesforce
        classDoc = updatedClassDoc
        console.log "Upserting class to salesforce"
        return toSalesforce.upsertClass(classDoc)
      ).then( (results)->
        #Upsert the class in MongoDB
        console.log "Upserting to mongodb"
        classDoc.attendance_report_salesforce_id = results.id
        classDoc.errors = results?.errors or []
        if( classDoc._id )
          return Promise.resolve( Classes.update { _id: classDoc._id }, { $set: classDoc })
        else
          return Promise.resolve( Classes.insert classDoc )
        # if not classDoc._id
        #   return Promise.resolve( Classes.insert classDoc )
        # else
      ).then(( results )->
        #export class educators to Salesforce
        console.log "Exporting class educators"
        return toSalesforce.exportClassEducators( classDoc.educators, classDoc.facility_salesforce_id, classDoc.attendance_report_salesforce_id )
      ).then(( results )->
        #delete necessary educator records
        console.log "Deleting class educators"
        classDoc.educators = results.educators
        if results.errors
          console.log "Errors exporting class educators"
          console.log results.errors
          classDoc.errors = classDoc.errors.concat results.errors
        id = classDoc.attendance_report_salesforce_id
        Classes.update { attendance_report_salesforce_id: id }, { $set: classDoc }

        toDelete = deletedEducators
          .filter((educator)->
            id = educator.class_educator_salesforce_id
            return id? and id != ''
          ).map (educator) ->
            return educator.class_educator_salesforce_id
        return toSalesforce.deleteRecords(toDelete, "Class_Educator__c")
      ).then(( deleteResults )->
        #upsert attendee records in Salesforce
        if deleteResults.errors
          console.log "Errors deleting class educators"
          console.log deleteResults.errors
          classDoc.errors = classDoc.errors.concat deleteResults.errors
        console.log "Upserting attendees"
        return toSalesforce.upsertAttendees(classDoc, classDoc.attendees)
      ).then( (results)->
        #delete necessary attendee records
        classDoc.attendees = results.attendees
        if results.errors
          console.log "Errors upserting attendees"
          console.log results.errors
          classDoc.errors = classDoc.errors.concat results.errors
        id = classDoc.attendance_report_salesforce_id
        Classes.update { attendance_report_salesforce_id: id }, { $set: classDoc }

        toDelete = deletedAttendees
          .filter((attendee)->
            id = attendee.contact_salesforce_id
            return id? and id != ''
          ).map (attendee) ->
            return attendee.contact_salesforce_id
        console.log "Deleting attendees"
        return toSalesforce.deleteRecords(toDelete, "Contact")
      ).then( (results)->
        #return results and errors to the client
        if results.errors
          console.log "Errors deleting attendees"
          console.log results.errors
          classDoc.errors = classDoc.errors.concat results.errors
        console.log "Returning to client"
        return { doc: classDoc, syncErrors: classDoc.errors }
      , (err)->
        throw err
      )

    "assignPatientIds": ( classDoc )->
      getUniqueId = ( classDoc )->

        getInitials = ( name, location )->
          words = name.split " "
          letters = words.map (word)->
            cleaned = word.replace(/[^a-zA-Z]/g, "")
            return cleaned[0]?.toUpperCase()
          letters.push(location[0]?.toUpperCase())
          return letters.join("")

        initials = getInitials( classDoc.facility_name, classDoc.location )
        result = UniqueID.findOne({ name: initials })
        id = 0
        if not result
          UniqueID.insert { name: initials, currentUniqueID: id }
        else
          id = result.currentUniqueID

        UniqueID.update { name: initials }, { $inc:{ currentUniqueID: 1 }}
        return initials + moment(classDoc.date).format("YYMMDD") + id

      for attendee, i in classDoc.attendees
        if not attendee.patient_id or attendee.patient_id == ''
          classDoc.attendees[i].patient_id = getUniqueId classDoc

      return classDoc


module.exports.NooraClass = NooraClass
