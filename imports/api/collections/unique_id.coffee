
UniqueID = new Mongo.Collection Meteor.settings.public.unique_id_collection

UniqueIDCollection = new SimpleSchema
  name:
    type: String
  currentUniqueID:
    type: Number

UniqueID.attachSchema UniqueIDCollection

module.exports.UniqueID = UniqueID
