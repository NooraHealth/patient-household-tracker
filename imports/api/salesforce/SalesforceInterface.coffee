{ Educators } = require "../collections/educators.coffee"
{ Facilities } = require "../collections/facilities.coffee"
{ Classes } = require "../collections/classes.coffee"
{ getDateTime } = require "../utils.coffee"

class SalesforceInterface

  constructor: ->
    login = Salesforce.login Meteor.settings.SF_USER, Meteor.settings.SF_PASS, Meteor.settings.SF_TOKEN
    console.log login

  exportClassEducators: ( classDoc )->
    return new Promise (resolve, reject)->
      toExport = classDoc.educators.filter (educator)->
        id = educator.class_educator_salesforce_id
        if not id? or id is ''
          return true

      console.log "Exporting these educators:"
      console.log classDoc.educators
      console.log toExport
      if toExport.length is 0
        resolve classDoc.educators
        return

      facility = Facilities.findOne {
        salesforce_id: classDoc.facility_salesforce_id
      }

      educators = toExport.map ( educator )->
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
          educator.export_error = err
        else
          console.log "Successfulll exported"
          educator.export_error = null
          educator.class_educator_salesforce_id = ret.id
        updatedEducators.push educator
        if updatedEducators.length == toExport.length
          educators = classDoc.educators.map (educator, i)->
            updatedEducator = updatedEducators[i]
            if updatedEducator? and updatedEducator.contact_salesforce_id == educator.contact_salesforce_id
              return updatedEducator
            else
              return educator
          resolve educators

      #insert into the Salesforce database
      for educator, i in educators
        Salesforce.sobject("Class_Educator__c").insert educator, callback.bind(this, classDoc.educators[i] )

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
          console.log "Successfully inserted attendee"
          attendee.export_error = null
          attendee.contact_salesforce_id = ret.id
        updatedAttendees.push attendee
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


  deleteAttendees: ( attendees )->
    return new Promise ( resolve, reject )->
      console.log "Attndees to delete"
      attendees = attendees.filter (attendee)-> return attendee.contact_salesforce_id? and attendee.contact_salesforce_id != ''
      console.log attendees
      console.log attendees.length
      if attendees.length == 0
        resolve []
      else
        ids = attendees.map (attendee)-> return attendee.contact_salesforce_id
        result = Salesforce.sobject("Contact").find(
          { 'Id' : {$in: ids} },
          {
            Id: 1,
            Name: 1
          }
        ).execute( (err, contacts )->
          console.log "Contacts found"
          console.log contacts.length
          if contacts.length is 0
            reject "Contacts not found in salesforce"
          for contact in contacts
            Salesforce.sobject("Contact").destroy contact.Id, (err, ret)->
              if err
                console.log "Error deleting attendee #{contact.Id}"
                console.log err
                reject err
              else
                console.log "Successfully deleted the contact"
                resolve( ret )
        )

  exportClass: ( nooraClass )->
    return new Promise (resolve, reject)->
      #if nooraclass has already been uploaded
      id = nooraClass.attendance_report_salesforce_id
      if id? and id != ''
        resolve( id )
        return

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
      Salesforce.sobject("Attendance_Report__c").insert salesforceObj, callback

module.exports.SalesforceInterface = SalesforceInterface
