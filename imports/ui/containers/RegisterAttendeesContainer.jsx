
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

  this._getDiagnosisOptions = function( classes ) {
    let previousDiagnoses = AppConfig.getBaseDiagnoses();
    classes.forEach( function( nooraClass ) {
      nooraClass.attendees.forEach(function(attendee){
        if(attendee.diagnosis){
          previousDiagnoses.push(attendee.diagnosis);
        }
      });
    });
    filtered = []
    previousDiagnoses.forEach( function(diagnosis){
      if( filtered.indexOf(diagnosis) == -1){
        filtered.push(diagnosis);
      };
    });
    return filtered;
  };

  const numAttendees = (params.mode == "editAttendees" && classDoc)? classDoc.attendees.length: params.numAttendees;
  return {
    loading: !(educators_handle.ready() && classes_handle.ready()) ,
    classDoc: classDoc,
    diagnoses: _getDiagnosisOptions( Classes.find({}).fetch() ),
    mode: params.mode,
    numAttendees: numAttendees,
    supportedLanguages: AppConfig.getSupportedLanguages(),
    currentFacilityName: AppConfig.getFacilityName()
  };
}, RegisterAttendeesPage);

export { RegisterAttendeesContainer };
