
Immutable = require 'immutable'
moment = require 'moment'
{ Facilities } = require '../collections/facilities.coffee'
{ Classes } = require '../collections/classes.coffee'
{ ClassesSchema } = require '../collections/classes.coffee'

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
          console.log results
          console.log Classes.find({}).fetch()
          AttendeesListDoc = Classes.findOne { _id: results._id }
          Meteor.call "syncWithSalesforce", AttendeesListDoc
          resolve AttendeesList

if Meteor.isServer
  { SalesforceInterface } = require '../salesforce/SalesforceInterface.coffee'

  Meteor.methods
    "syncWithSalesforce": ( AttendeesList )->
      console.log AttendeesList
      console.log "THIS IS WHERE YOU EXPORT TO SALESFORCE"

    "AttendeesList.insert": ( AttendeesList )->
      console.log "Saving this AttendeesList"
      facility = Facilities.findOne { name: AttendeesList.facility_name }
      if not facility
        throw new Meteor.Error "Facility Does Not Exist", "That facility is not in the database. Ensure that the facility exists in Salesforce and has been synced with the app"
      AttendeesList.facility_salesforce_id = facility.salesforce_id
      ClassesSchema.clean(AttendeesList)
      ClassesSchema.validate(AttendeesList);
      return Classes.insert AttendeesList

module.exports.AttendeesList = AttendeesList
