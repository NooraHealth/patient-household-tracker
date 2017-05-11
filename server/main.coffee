
{ Educators } = require '../imports/api/collections/educators.coffee';
{ UniqueID } = require '../imports/api/collections/unique_id.coffee';
{ Classes } = require '../imports/api/collections/classes.coffee';
{ Facilities } = require '../imports/api/collections/facilities.coffee';
{ ConditionOperations } = require '../imports/api/collections/condition_operations.coffee';
{ NooraClass } = require '../imports/api/immutables/NooraClass.coffee';
{ SalesforceInterface } = require '../imports/api/salesforce/SalesforceInterface.coffee';
require '../imports/api/immutables/NooraClass.coffee';
moment = require 'moment'

Meteor.startup ()->

  console.log process.env.MONGO_URL
