import { createContainer } from 'meteor/react-meteor-data';
import { AddClassPage } from '../pages/AddClass.jsx';
import { Educators } from '../../api/collections/educators.coffee';
import { Classes } from '../../api/collections/classes.coffee';
import { NooraClass } from '../../api/immutables/NooraClass.coffee';
import { AppConfig } from '../../api/AppConfig.coffee';

export default AddClassContainer = createContainer(( params ) => {
  var educators_handle = Meteor.subscribe("educators.all");
  /* TODO: this will eventually be published by facility. Rm autopublish */
  var classes_handle = Meteor.subscribe("classes.all");

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
    nooraClass: new NooraClass(),
    currentFacilityName: AppConfig.getFacilityName()
  };
}, AddClassPage);

export { AddClassContainer };
