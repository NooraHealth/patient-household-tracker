
{ Educators } = require '../imports/api/collections/educators.coffee';
{ Classes } = require '../imports/api/collections/classes.coffee';
{ Facilities } = require '../imports/api/collections/facilities.coffee';
{ ConditionOperations } = require '../imports/api/collections/condition_operations.coffee';
require '../imports/api/immutables/NooraClass.coffee';

Meteor.startup ()->
  console.log process.env.MONGO_URL
