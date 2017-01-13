
Classes = new Mongo.Collection Meteor.settings.public.classes_collection

ClassesSchema = new SimpleSchema
  name:
    type: String
    defaultValue: ""
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
  "attendees.$.is_patient":
    type: Boolean
  "attendees.$.language":
    type: String
  "attendees.$.phone_1":
    type: String
  "attendees.$.phone_2":
    type: String
    optional: true

Classes.attachSchema ClassesSchema

module.exports.Classes = Classes
module.exports.ClassesSchema = ClassesSchema
