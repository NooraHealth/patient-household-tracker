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

  _getAvailableEducators = function( facilityName ){
    return Educators.find({ facility_name: facilityName }).fetch();
  };

  _getConditionOperations = function( facilityName ) {
    return ConditionOperations.find({ facility_name: facilityName }).fetch();
  };

  _getClass = function( reportId ) {
    let nooraClass = Classes.findOne({ _id: reportId });
    if( !nooraClass ) return nooraClass;
    nooraClass.educators = nooraClass.educators.map((educator) => {
      const doc = Educators.findOne({ contact_salesforce_id: educator.contact_salesforce_id });
      if( doc ){
        educator.first_name = doc.first_name;
        educator.last_name = doc.last_name;
        educator.uniqueId = doc.uniqueId;
      }
      return educator;
    });
    return nooraClass;
  };

  _getClassLocations = function( classes ) {
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
    classDoc: _getClass(params.reportId),
    supportedLanguages: AppConfig.getSupportedLanguages(),
    availableEducators: _getAvailableEducators( AppConfig.getFacilityName() ),
    conditionOperations: _getConditionOperations( AppConfig.getFacilityName() ),
    currentFacilityName: AppConfig.getFacilityName(),
    facilitySalesforceId: AppConfig.getFacilityId()
  };
}, AddClassPage);

export { AddClassContainer };
