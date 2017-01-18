
import { createContainer } from 'meteor/react-meteor-data';
import { SelectClassPage } from '../pages/SelectClass.jsx';
import { Classes } from '../../api/collections/classes.coffee';
import { AppConfig } from '../../api/AppConfig.coffee';

export default SelectClassContainer = createContainer(( params ) => {
  /* TODO: this will eventually be published by facility. Rm autopublish */
  var classes_handle = Meteor.subscribe("classes.all");
  var educators_handle = Meteor.subscribe("educators.all");

  this._getClasses = function( facilityName ){
    return Classes.find({ facility_name: facilityName }).fetch().reverse();
  };

  return {
    loading: !(educators_handle.ready() && classes_handle.ready()) ,
    classes: _getClasses( AppConfig.getFacilityName() ),
    currentFacilityName: AppConfig.getFacilityName()
  };
}, SelectClassPage);

export { SelectClassContainer };
