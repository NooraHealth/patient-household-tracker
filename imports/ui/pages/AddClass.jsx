  'use strict';

import React from 'react';
import moment from 'moment';
import Immutable from 'immutable'
import { Form } from '../components/form/base/Form.jsx';
import { NooraClass } from '../../api/immutables/NooraClass.coffee';
import { SelectFacilityContainer } from '../containers/SelectFacilityContainer.jsx';

var AddClassPage = React.createClass({

  propTypes: {
    currentFacilityName: React.PropTypes.string,
    loading: React.PropTypes.bool,
    locations: React.PropTypes.array
  },

  defaultProps() {
    return {
      currentFacilityName: "",
      locations: [],
      nooraClass: null,
      loading: true
    }
  },

  getInitialState() {
    const nooraClass = this.props.nooraClass.set("facility_name", this.props.currentFacilityName);
    return {
      loading: false,
      nooraClass: nooraClass
    }
  },

  componentDidUpdate(prevProps, prevState) {
    if( this.props.currentFacilityName !== prevProps.currentFacilityName){
      let nooraClass = this.state.nooraClass.set("facility_name", this.props.currentFacilityName );
      this.setState({ nooraClass: nooraClass });
    }
  },

  render() {
    let submitText = "SAVE CLASS";
    if( this.state.loading )
      submitText = "...loading..."
    const source = this.props.locations.map( function(location){
        return { title: location };
    });

    return (
      <div>
        <Form onSubmit={ this._onSubmit } submitButtonContent={ submitText } disabled={ this.state.loading } >
          <SelectFacilityContainer/>
          <Form.Search
            key= 'class_location'
            placeholder="Location"
            icon="search icon"
            value={ this.state.nooraClass.location }
            onChange={ this._handleChange("location") }
            source={ source }
          />
        </Form>
      </div>
    )
  },

  _clearForm(){
    let nooraClass = new NooraClass();
    nooraClass = nooraClass.set("facility_name", this.props.currentFacilityName);
    this.setState({
      nooraClass: nooraClass,
      loading: false
    });
  },

  _onSubmit() {
    const that = this;
    try {
      swal({
        type: "info",
        closeOnConfirm: true,
        showCancelButton: true,
        text: "Are you sure you want to register this class?",
        title: "Confirm"
      }, function( isConfirm ) {
        if( !isConfirm ) {
          that.setState({ loading: false });
          return;
        }
        that.setState({ loading: true });
        that._saveClass()
      });
    } catch(error) {
      this.setState({ loading: false });
      swal({
        type: "error",
        title: "Oops!",
        text: error.message
      });
    }
  },

  _handleChange(field) {
    return (value) => {
      const nooraClass = this.state.nooraClass.set(field, value);
      this.setState({ nooraClass: nooraClass })
    }
  },

  _saveClass(nooraClass) {
    const that = this;
    const showPopup = ( options, callback )=> {
      Meteor.setTimeout( ()=> {
        swal(options, callback);
      }, 100 );
    };

    const onSaveSuccess = function( nooraClass ){
      const text = "Name: "  + nooraClass.name;
      that._clearForm();
      showPopup({
        type: "success",
        title: "Class Saved Successfully",
        text: text
      });
    };

    const onSaveError = function(error) {
      that.setState({ loading: false });
      showPopup({
        type: "error",
        text: error.message,
        title: "Error inserting class into database"
      });
    }
    this.state.nooraClass.save().then( results => onSaveSuccess(results), error => onSaveError(error))
  }
});

export { AddClassPage };
