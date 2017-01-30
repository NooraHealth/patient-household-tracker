
Classes = new Mongo.Collection Meteor.settings.public.classes_collection

ClassesSchema = new SimpleSchema
  name:
    type: String
    defaultValue: ""
    unique: true
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
  facility_salesforce_id:
    type: String
    defaultValue: ""
  attendance_report_salesforce_id:
    type: String
    defaultValue: ""
    optional: true
  facility_name:
    type: String
    defaultValue: ""
  date_created:
    type: String
    defaultValue: ""
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
  export_class_error:
    type: Boolean
    defaultValue: false
    optional: true
  export_attendees_error:
    type: Boolean
    defaultValue: false
    optional: true
  #TODO: Make all references to salesforce ids the same term
  "educators.$.contact_salesforce_id":
    type: String
  "educators.$.error_exporting":
    type: [Object]
    optional: true
  "educators.$.class_educator_salesforce_id":
    type: String
    optional: true
  "attendees.$.name":
    type: String
  "attendees.$.error_exporting":
    type: [Object]
    optional: true
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
