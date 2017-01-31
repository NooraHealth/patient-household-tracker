import { createContainer } from 'meteor/react-meteor-data';
import { AddClassPage } from '../pages/AddClass.jsx';
import { Educators } from '../../api/collections/educators.coffee';
import { ConditionOperations } from '../../api/collections/condition_operations.coffee';
import { Classes } from '../../api/collections/classes.coffee';
import { NooraClass } from '../../api/immutables/NooraClass.coffee';
import { AppConfig } from '../../api/AppConfig.coffee';

export default AddClassContainer = createContainer(( params ) => {
  var educators_handle = Meteor.subscribe("educators.all");
  /* TODO: this will eventually be published by facility. Rm autopublish */
  var classes_handle = Meteor.subscribe("classes.all");
  var condition_ops_handle = Meteor.subscribe("condition_operations.all");

  this._getAvailableEducators = function( facilityName ){
    return Educators.find({ facility_name: facilityName }).fetch();
  };

  this._getConditionOperations = function( facilityName ) {
    return ConditionOperations.find({ facility_name: facilityName }).fetch();
  };

  this._getClass = function( name ) {
    return Classes.findOne({ name: name });
  };

  this._getClassLocations = function( classes ) {
    const locations = classes.map( function( nooraClass ) {
      return nooraClass.location;
    });
    filtered = []
    locations.forEach( function(location){
      if( filtered.indexOf(location) == -1){
        filtered.push(location);
      };
    });
    return filtered;
  };

  return {
    loading: !(educators_handle.ready() && classes_handle.ready()) ,
    locations: _getClassLocations( Classes.find({ facility_name: AppConfig.getFacilityName() }).fetch() ),
    classDoc: _getClass(params.className),
    supportedLanguages: AppConfig.getSupportedLanguages(),
    availableEducators: _getAvailableEducators( AppConfig.getFacilityName() ),
    conditionOperations: _getConditionOperations( AppConfig.getFacilityName() ),
    currentFacilityName: AppConfig.getFacilityName()
  };
}, AddClassPage);

export { AddClassContainer };
