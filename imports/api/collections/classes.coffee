
Classes = new Mongo.Collection Meteor.settings.public.classes_collection

ClassesSchema = new SimpleSchema
  name:
    type: String
    defaultValue: ""
    unique: true
  location:
    type: String
    defaultValue: ""
  educators:
    type: [String]
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
  record_salesforce_id:
    type: String
    defaultValue: ""
    optional: true
  facility_name:
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
  "attendees.$.name":
    type: String
  "attendees.$.patient_attended":
    type: Boolean
    optional: true
  "attendees.$.language":
    type: String
    optional:true
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
