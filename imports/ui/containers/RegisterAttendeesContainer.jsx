
import { createContainer } from 'meteor/react-meteor-data';
import { RegisterAttendeesPage } from '../pages/RegisterAttendees.jsx';
import { Classes } from '../../api/collections/classes.coffee';
import { NooraClass } from '../../api/immutables/NooraClass.coffee';
import { AppConfig } from '../../api/AppConfig.coffee';

export default RegisterAttendeesContainer = createContainer(( params ) => {
  /* TODO: this will eventually be published by facility. Rm autopublish */
  var classes_handle = Meteor.subscribe("classes.all");
  var educators_handle = Meteor.subscribe("educators.all");

  var classDoc = Classes.findOne({ name: params.className });

  return {
    loading: !(educators_handle.ready() && classes_handle.ready()) ,
    classDoc: classDoc,
    numAttendees: params.numAttendees,
    currentFacilityName: AppConfig.getFacilityName()
  };
}, RegisterAttendeesPage);

export { RegisterAttendeesContainer };
