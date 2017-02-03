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
      console.log "original educators"
      console.log educators

      console.log "Exporting these educators"
      console.log toExport
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
      callback = Meteor.bindEnvironment ( educator, err, ret ) ->
        console.log "The return"
        console.log err
        console.log ret
        if err
          educator.export_error = err
          console.log "ERror exporting class educators!!"
          console.log err
        else
          console.log "Changing the stuff on the educatro"
          educator.export_error = null
          educator.class_educator_salesforce_id = ret.id
        updatedEducators.push educator
        console.log "The updated educators!"
        console.log updatedEducators
        console.log "The educators"
        console.log educators

        if updatedEducators.length == toExport.length
          educators = educators.map (educator, i)->
            for updatedEducator in updatedEducators
              if updatedEducator? and updatedEducator.contact_salesforce_id == educator.contact_salesforce_id
                console.log "Returning the updated educator"
                console.log updatedEducator
                return updatedEducator
              else
                console.log "returning the educator"
                console.log educator
                return educator
          console.log "The educatorsj"
          console.log educators
          resolve educators

      #insert into the Salesforce database
      for classEducator, i in classEducatorObjects
        console.log "The class educator object"
        console.log classEducator
        Salesforce.sobject("Class_Educator__c").insert classEducator, callback.bind(this, toExport[i] )

  upsertAttendees: ( classDoc, attendees )->
    return new Promise (resolve, reject)->
      console.log "Upserting attendees"
      if attendees.length is 0
        resolve []
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
          "Languages__c" : attendee.language,
          "Diagnosis__c" : attendee.diagnosis,
          "Number_Family_Members_Attended_Class__c" : attendee.num_caregivers_attended,
          "Attendance_Report__c" : classDoc.attendance_report_salesforce_id,
          "AccountId" : facility.delivery_partner,
          "RecordTypeId": "012j00000010Ggc"
      }

      updatedAttendees = []
      callback = Meteor.bindEnvironment ( attendee, err, ret ) ->
        if err
          console.log "Error exporting class attendees"
          console.log err
          attendee.export_error = err
        else
          "Successfully exported"
          attendee.export_error = null
          attendee.contact_salesforce_id = ret.id
        updatedAttendees.push attendee
        console.log "updated attendees"
        console.log updatedAttendees
        if updatedAttendees.length == attendees.length
          resolve( updatedAttendees )

      i = 0
      upsertNextAttendee = ->
        contact = contacts[i]
        attendee = attendees[i]
        recordId = attendee.contact_salesforce_id
        if recordId? and recordId != ''
          contact.Id = recordId
          Salesforce.sobject("Contact").update contact, "Id", callback.bind(this, attendee )
        else
          Salesforce.sobject("Contact").insert contact, callback.bind(this, attendee )
        i = ++i
        if i is contacts.length
          Meteor.clearInterval(this.handle)

      this.handle = Meteor.setInterval(upsertNextAttendee.bind(this), 300)


  deleteRecords: (ids, objectName )->
    return new Promise (resolve, reject)->
      console.log "Deleting records"
      console.log ids
      if ids.length is 0
        resolve()
      else
        deleted = 0
        for id in ids
          Salesforce.sobject(objectName).destroy id, (err, ret)->
            if err
              console.log "Error deleting record #{id}"
              console.log err
              reject err
            else
              console.log "Successfully deleted the record #{id}"
            deleted = ++deleted
            if deleted == ids.length
              resolve()

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
          reject(err)
        else
          console.log "ret"
          console.log ret.id
          resolve(ret.id)

      #insert into the Salesforce database
      id = nooraClass.attendance_report_salesforce_id
      if id? and id != ''
        salesforceObj.Id = id
        Salesforce.sobject("Attendance_Report__c").update salesforceObj, "Id", callback
      else
        console.log "exporting class"
        Salesforce.sobject("Attendance_Report__c").insert salesforceObj, callback

module.exports.SalesforceInterface = SalesforceInterface
