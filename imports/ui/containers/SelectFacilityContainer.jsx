
import { createContainer } from 'meteor/react-meteor-data';
import { Search } from '../components/form/Search.jsx';
import { Facilities } from '../../api/collections/facilities.coffee';
import { AppConfig } from '../../api/AppConfig.coffee';

export default SelectFacilityContainer = createContainer(() => {
  // Do all your reactive data access in this method.
  // Note that this subscription will get cleaned up when your component is unmounted
  var handle = Meteor.subscribe("facilities.all");

  this._onChange = function(value) {
    AppConfig.setFacilityName( value );
  };

  this._getFacilityNames = function( facilities ) {
    const names= facilities.map( function( facility ){
      return facility.name;
    });
    return names.map( function(name){
        return { title: name };
    });
  };

  return {
    loading: ! handle.ready(),
    source: _getFacilityNames( Facilities.find({}).fetch() ),
    label: "Facility",
    value: AppConfig.getFacilityName(),
    placeholder: " Search Facilities",
    onChange: _onChange
  };
}, Search);

export { SelectFacilityContainer };
