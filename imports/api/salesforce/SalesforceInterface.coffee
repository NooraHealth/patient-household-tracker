{ Educators } = require "../collections/educators.coffee"
{ Facilities } = require "../collections/facilities.coffee"
{ Classes } = require "../collections/classes.coffee"
{ getDateTime } = require "../utils.coffee"

class SalesforceInterface

  constructor: ->
    login = Salesforce.login Meteor.settings.SF_USER, Meteor.settings.SF_PASS, Meteor.settings.SF_TOKEN

  exportClassEducators: ( classDoc )->
    return new Promise (resolve, reject)->
      if classDoc.educators.length is 0
        resolve []


      facility = Facilities.findOne {
        salesforce_id: classDoc.facility_salesforce_id
      }

      educators = classDoc.educators.map ( educator )->
        doc = Educators.findOne { contact_salesforce_id: educator.contact_salesforce_id }
        return {
          "Name": "Educator: #{doc.first_name} #{doc.last_name} (ID: #{doc.uniqueId})"
          "Attendance_Report__c": classDoc.attendance_report_salesforce_id
          "Class_Educator__c": educator.contact_salesforce_id
      }

      updatedEducators = []
      callback = Meteor.bindEnvironment ( educator, err, ret ) ->
        if err
          console.log "Error exporting class educators"
          console.log err
          reject(err)
        else
          educator.class_educator_salesforce_id = ret.id
        updatedEducators.push educator
        if updatedEducators.length == classDoc.educators.length
          resolve updatedEducators

      #insert into the Salesforce database
      for educator, i in educators
        Salesforce.sobject("Class_Educator__c").insert educator, callback.bind(this, classDoc.educators[i] )

  upsertAttendees: ( classDoc, attendees )->
    return new Promise (resolve, reject)->
      if attendees.length is 0
        resolve({ successful: [], errored: [] })

      facility = Facilities.findOne {
        salesforce_id: classDoc.facility_salesforce_id
      }

      contacts = attendees.map ( attendee )->
        return {
          "LastName" : attendee.name
          "MobilePhone" : attendee.phone_1 or 0,
          "HomePhone" : attendee.phone_2 or 0,
          "Patient_Attended_Class__c" : attendee.patient_attended,
          "Languages__c" : attendee.language,
          "Diagnosis__c" : attendee.diagnosis,
          "Number_Family_Members_Attended_Class__c" : attendee.num_caregivers_attended,
          "Attendance_Report__c" : classDoc.attendance_report_salesforce_id,
          "AccountId" : facility.delivery_partner,
          "RecordTypeId": "012j00000010Ggc"
      }

      updatedAttendees = []
      erroredAttendees = []
      callback = Meteor.bindEnvironment ( attendee, err, ret ) ->
        if err
          console.log "Error exporting class attendees"
          console.log err
          erroredAttendees.push(attendee)
        else
          attendee.contact_salesforce_id = ret.id
          updatedAttendees.push attendee
        if((erroredAttendees.length + updatedAttendees.length) == attendees.length)
          resolve({ successful: updatedAttendees, errored: erroredAttendees} )

      #insert into the Salesforce database
      for contact, i in contacts
        Salesforce.sobject("Contact").insert contact, callback.bind(this, attendees[i] )

  deleteAttendees: ( attendanceReportId, attendeeContactIds )->
    return new Promise ( resolve, reject )->
      result = Salesforce.sobject("Contact").find(
        { 'Attendance_Report__c.Id' : attendanceReportId },
        {
          Id: 1,
          Name: 1
        }
      ).execute( (err, attendees)->
        deleted = 0
        if attendees is undefined or attendees.length == 0
          console.log "Attendees was undefined or length 0"
          resolve()
        for attendee in attendees
          if attendee.Id in attendeeContactIds
            Salesforce.sobject("Contact").destroy attendee.Id, (err, ret)->
              if err
                console.log "Error deleting condition operations"
                console.log err
                reject err
              else
                console.log "deleted!!"
                deleted++
                if deleted == attendeeContactIds.length
                  resolve()
      )

  exportClass: ( nooraClass )->
    return new Promise (resolve, reject)->
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
          console.log "Error exporting nurse educator"
          console.log err
          reject(err)
        else
          console.log "ret"
          console.log ret.id
          resolve(ret.id)

      #insert into the Salesforce database
      Salesforce.sobject("Attendance_Report__c").insert salesforceObj, callback

module.exports.SalesforceInterface = SalesforceInterface
