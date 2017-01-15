
ListOfAttendees = new Mongo.Collection Meteor.settings.public.ListOfAttendees_collection

ListOfAttendeesSchema = new SimpleSchema
  name:
    type: String
    defaultValue:""
  patient_attended:
    type: Boolean
  language:
    type: String
  num_caregivers_attended:
    type: Number
  phone_1:
    type: String
  phone_2:
    type: String
    optional: true

ListOfAttendees.attachSchema ListOfAttendeesSchema

module.exports.ListOfAttendees = ListOfAttendees
module.exports.ListOfAttendeesSchema = ListOfAttendeesSchema
