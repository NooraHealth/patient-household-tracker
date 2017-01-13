
import { createContainer } from 'meteor/react-meteor-data';
import { AddAttendeesPage } from '../pages/AddAttendees.jsx';
import { Classes } from '../../api/collections/classes.coffee';
import { AttendeesList } from '../../api/immutables/AttendeesList.coffee';
import { AppConfig } from '../../api/AppConfig.coffee';

export default AddAttendeesContainer = createContainer(( params ) => {
  /* TODO: this will eventually be published by facility. Rm autopublish */
  var classes_handle = Meteor.subscribe("classes.all");
  var educators_handle = Meteor.subscribe("educators.all");

  this._getClasses = function( facilityName ){
    return Classes.find({ facility_name: facilityName }, {$sort: { date_created: -1 }}).fetch()
  };

  return {
    loading: !(educators_handle.ready() && classes_handle.ready()) ,
    classes: _getClasses( AppConfig.getFacilityName() ),
    attendees: new AttendeesList(),
    currentFacilityName: AppConfig.getFacilityName()
  };
}, AddAttendeesPage);

export { AddAttendeesContainer };
