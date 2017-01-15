
Immutable = require 'immutable'
moment = require 'moment'
{ Facilities } = require '../collections/facilities.coffee'
{ Classes } = require '../collections/classes.coffee'
{ ListOfAttendees } = require '../collections/list_of_attendees.coffee'
{ ListOfAttendeesSchema } = require '../collections/list_of_attendees.coffee'

BaseAttendeesList = Immutable.Record {
  class_name: '',
  num_attendees: 3,
  attendees: Immutable.List()
}

class AttendeesList extends BaseAttendeesList
  constructor: ( properties )->
    super Object.assign({}, properties, {
      attendees: Immutable.List properties && properties.condition_operations
    });

  setClassName: ->
    console.log "Setting class name"
    return this.set "name", "#{ this.facility_name }: #{ this.location } - #{ this.date }  "

  save: ->
    AttendeesList = this
    return new Promise ( resolve, reject )->
      Meteor.call "attendees.insert", AttendeesList.toJS(), ( error, results )->
        if error
          reject error
        else
          classDoc = Classes.findOne { _id: results._id }
          Meteor.call "syncWithSalesforce", classDoc
          resolve classDoc

if Meteor.isServer
  { SalesforceInterface } = require '../salesforce/SalesforceInterface.coffee'

  Meteor.methods
    "syncWithSalesforce": ( listOfAttendees )->
      console.log AttendeesList
      console.log "THIS IS WHERE YOU EXPORT TO SALESFORCE"

    "AttendeesList.insert": ( listOfAttendees )->
      if listOfAttendees.num_attendees != listOfAttendees.attendees.lenth()
        throw new Meteor.Error 'invalid attendees', "Number of attendees must be #{ listOfAttendees.num_attendees }"
      ListOfAttendeesSchema.clean(listOfAttendees)
      ListOfAttendeesSchema.validate(listOfAttendees);
      return listOfAttendees.insert listOfAttendees

module.exports.AttendeesList = AttendeesList
