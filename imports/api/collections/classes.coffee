
{ Educators } = require "./educators"
moment = require 'moment'
Classes = new Mongo.Collection Meteor.settings.public.classes_collection

ClassesSchema = new SimpleSchema
  name:
    type: String
    autoValue: ()->
      endTime = if this.field("end_time").isSet then this.field("end_time").value else null
      startTime = this.field("start_time").value
      facilityName = this.field("facility_name").value
      location = this.field("location").value
      date = this.field("date").value
      suffix = if endTime then " to #{ endTime }" else ""
      return "#{ facilityName }: #{ location } - #{ date }, #{ startTime }#{ suffix }"
  location:
    type: String
    defaultValue: ""
  majority_language:
    type: String
    defaultValue: ""
  total_patients:
    type: Number
    defaultValue: ""
  total_family_members:
    type: Number
    defaultValue: ""
  condition_operation_salesforce_id:
    type: String
    defaultValue: ""
    min: 2
  facility_salesforce_id:
    type: String
    defaultValue: ""
  attendance_report_salesforce_id:
    type: String
    unique: true
  facility_name:
    type: String
    defaultValue: ""
  date_created:
    type: String
    autoValue: ()->
      console.log "Getting the date created"
      console.log this
      if not this.value
        return moment().toISOString()
  date:
    type: String
    defaultValue: ""
  start_time:
    type: String
    defaultValue: ""
  end_time:
    type: String
    defaultValue: ""
    optional:true
  errors:
    type: [Object]
    optional: true
    blackbox: true
  #TODO: Make all references to salesforce ids the same term
  "educators.$.contact_salesforce_id":
    type: String
    custom: ->
      console.log "Custom validation of educators"
      educator = Educators.findOne { contact_salesforce_id: this.value }
      console.log educator
      if not educator
        console.log "Not educator!"
        return "notAllowed"
  "educators.$.first_name":
    type: String
    optional: true
  "educators.$.last_name":
    type: String
    optional: true
  "educators.$.uniqueId":
    type: String
    optional: true
  "educators.$.class_educator_salesforce_id":
    type: String
    optional: true
  "attendees.$.name":
    type: String
  "attendees.$.contact_salesforce_id":
    type: String
    defaultValue: ''
    optional: true
  "attendees.$.patient_attended":
    type: Boolean
    optional: true
  "attendees.$.language":
    type: String
  "attendees.$.diagnosis":
    type: String
    optional: true
    defaultValue: null
  "attendees.$.num_caregivers_attended":
    type: Number
  "attendees.$.phone_1":
    type: String
    optional:true
  "attendees.$.phone_2":
    type: String
    optional: true

Classes.attachSchema ClassesSchema

module.exports.Classes = Classes
module.exports.ClassesSchema = ClassesSchema
