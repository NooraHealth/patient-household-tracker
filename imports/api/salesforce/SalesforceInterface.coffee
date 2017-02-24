{ Educators } = require "../collections/educators.coffee"
{ Facilities } = require "../collections/facilities.coffee"
{ Classes } = require "../collections/classes.coffee"
{ getDateTime } = require "../utils.coffee"

class SalesforceInterface

  constructor: ->
    login = Salesforce.login Meteor.settings.SF_USER, Meteor.settings.SF_PASS, Meteor.settings.SF_TOKEN
    console.log login

  exportClassEducators: ( educators, facilityId, attendanceReportId )->
    return new Promise (resolve, reject)->
      toExport = educators.filter (educator)->
        id = educator.class_educator_salesforce_id
        return !(id? and id != '')
      if toExport.length is 0
        resolve( educators )
        return

      facility = Facilities.findOne {
        salesforce_id: facilityId
      }

      classEducatorObjects = toExport.map ( educator )=>
        doc = Educators.findOne { contact_salesforce_id: educator.contact_salesforce_id }
        return {
          "Name": "Educator: #{doc.first_name} #{doc.last_name} (ID: #{doc.uniqueId})"
          "Attendance_Report__c": attendanceReportId
          "Class_Educator__c": educator.contact_salesforce_id
      }

      updatedEducators = []
      errors = []
      callback = Meteor.bindEnvironment ( educator, err, ret ) ->
        if err
          console.log "ERror exporting class educators!!"
          console.log err
          console.log educator
          errors.push { "Error exporting class educator": err.name }
        else
          educator.export_error = null
          educator.class_educator_salesforce_id = ret.id
        updatedEducators.push educator
        if updatedEducators.length == toExport.length
          educators = educators.map (educator, i)->
            for updatedEducator in updatedEducators
              if updatedEducator? and updatedEducator.contact_salesforce_id == educator.contact_salesforce_id
                return updatedEducator
              else
                return educator
          resolve { educators: educators, errors: errors }

      #insert into the Salesforce database
      for classEducator, i in classEducatorObjects
        Salesforce.sobject("Class_Educator__c").insert classEducator, callback.bind(this, toExport[i] )

  upsertAttendees: ( classDoc, attendees )->
    return new Promise (resolve, reject)->
      if attendees.length is 0
        resolve { result: [], errors: [] }
        return

      facility = Facilities.findOne {
        salesforce_id: classDoc.facility_salesforce_id
      }

      contacts = attendees.map ( attendee )->
        return {
          "LastName" : attendee.name
          "MobilePhone" : attendee.phone_1 or 0,
          "HomePhone" : attendee.phone_2 or 0,
          "Patient_Attended_Class__c" : attendee.patient_attended,
          "Patient_Id__c" : attendee.patient_id,
          "Languages__c" : attendee.language,
          "Diagnosis__c" : attendee.diagnosis,
          "Number_Family_Members_Attended_Class__c" : attendee.num_caregivers_attended,
          "Attendance_Report__c" : classDoc.attendance_report_salesforce_id,
          "AccountId" : facility.delivery_partner,
          "RecordTypeId": "012j00000010Ggc"
      }

      updatedAttendees = []
      errors = []
      callback = Meteor.bindEnvironment ( attendee, err, ret ) ->
        if err
          console.log "Error exporting class attendees"
          console.log err
          errors.push { "Error exporting class attendee": err.name }
        else
          "Successfully exported"
          attendee.export_error = null
          if ret.id
            attendee.contact_salesforce_id = ret.id
        updatedAttendees.push attendee
        if updatedAttendees.length == attendees.length
          resolve( { attendees: updatedAttendees, errors: errors } )

      i = 0
      upsertNextAttendee = ->
        Salesforce.sobject("Contact").upsert contacts[i], "Patient_Id__c", callback.bind(this, attendees[i] )
        i = ++i
        if i is contacts.length
          Meteor.clearInterval(this.handle)

      this.handle = Meteor.setInterval(upsertNextAttendee.bind(this), 500)


  deleteRecords: (ids, objectName )->
    return new Promise (resolve, reject)->
      if ids.length is 0
        resolve({})
      else
        deleted = 0
        errors = []
        for id in ids
          Salesforce.sobject(objectName).destroy id, (err, ret)->
            if err
              console.log "Error deleting record #{id}"
              errors.push { "Error deleting #{objectName} #{id}": err.name }
            else
              console.log "Successfully deleted the record #{id}"
            deleted = ++deleted
            if deleted == ids.length
              resolve({ errors: errors, deleted: ids })

  upsertClass: ( nooraClass )->
    return new Promise (resolve, reject)->
      #if nooraclass has already been uploaded

      facility = Facilities.findOne {
        salesforce_id: nooraClass.facility_salesforce_id
      }

      endTime = if nooraClass.end_time then getDateTime(nooraClass.date, nooraClass.end_time, "Asia/Kolkata") else null
      salesforceObj = {
        "Name": nooraClass.name
        "Condition_Operation__c": nooraClass.condition_operation_salesforce_id
        "Location__c": nooraClass.location
        "Num_Family_Members_Attended_Class__c": nooraClass.total_family_members
        "Num_Patients_Attended_Class__c": nooraClass.total_patients
        "Start_DateTime__c": getDateTime(nooraClass.date, nooraClass.start_time, "Asia/Kolkata")
        "End_DateTime__c": endTime
      }

      callback = Meteor.bindEnvironment ( err, ret ) ->
        if err
          console.log "Error exporting class"
          console.log err
          resolve({ errors: [{ "Error exporting/updating class": err.name }]})
        else
          console.log "ret"
          console.log ret.id
          resolve({ id: ret.id })

      #insert into the Salesforce database
      id = nooraClass.attendance_report_salesforce_id
      if id? and id != ''
        salesforceObj.Id = id
        Salesforce.sobject("Attendance_Report__c").update salesforceObj, "Id", callback
      else
        console.log "exporting class"
        Salesforce.sobject("Attendance_Report__c").insert salesforceObj, callback

module.exports.SalesforceInterface = SalesforceInterface
