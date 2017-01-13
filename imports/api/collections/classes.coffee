
Classes = new Mongo.Collection Meteor.settings.public.classes_collection

ClassesSchema = new SimpleSchema
  name:
    type: String
    defaultValue: ""
  location:
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

Classes.attachSchema ClassesSchema

module.exports.Classes = Classes
module.exports.ClassesSchema = ClassesSchema
