
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
    console.log "This to JS"
    console.log nooraClass
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
      classDoc.errors = []
      toSalesforce = new SalesforceInterface()
      promise = Promise.resolve( Meteor.call "assignPatientIds", classDoc)
      return promise.then( (newClassDoc) ->
        classDoc = newClassDoc
        return toSalesforce.upsertClass(classDoc)
      ).then( (results)->
        classDoc.attendance_report_salesforce_id = results.id
        classDoc.errors = results?.errors or []
        console.log "Class Doc id: #{classDoc._id}"
        if not classDoc._id
          console.log "Inserting a new document"
          return Promise.resolve(Classes.insert classDoc)
        else
          return Promise.resolve(Classes.update { _id: classDoc._id }, { $set: classDoc })
      ).then(( results )->
        console.log "Upserted the class"
        console.log results
        return toSalesforce.exportClassEducators( classDoc.educators, classDoc.facility_salesforce_id, classDoc.attendance_report_salesforce_id )
      ).then(( results )->
        console.log "Success exporting class educator objects"
        classDoc.educators = results.educators
        id = classDoc.attendance_report_salesforce_id
        if results.errors
          classDoc.errors = classDoc.errors.concat results.errors
        Classes.update { name: classDoc.name }, { $set: classDoc }
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

      for attendee in classDoc.attendees
        if not attendee.patient_id or attendee.patient_id == ''
          attendee.patient_id = getUniqueId classDoc
      return classDoc


module.exports.NooraClass = NooraClass
