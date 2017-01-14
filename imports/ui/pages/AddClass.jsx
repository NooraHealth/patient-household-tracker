  'use strict';

import React from 'react';
import moment from 'moment';
import Timepicker from 'rc-time-picker';
import Immutable from 'immutable'
import { Form } from '../components/form/base/Form.jsx';
import { Educators } from '../../api/collections/educators.coffee';
import { NooraClass } from '../../api/immutables/NooraClass.coffee';
import { SelectFacilityContainer } from '../containers/SelectFacilityContainer.jsx';
import DatePicker from 'react-datepicker';

var AddClassPage = React.createClass({

  propTypes: {
    currentFacilityName: React.PropTypes.string,
    loading: React.PropTypes.bool,
    availableEducators: React.PropTypes.array,
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
      nooraClass: nooraClass,
      startTime: null,
      endTime: null
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
    let dateOfClass = moment( this.state.nooraClass.date )
    let educatorOptions = this.props.availableEducators.map((educator)=> {
        return {
          value: educator.uniqueId,
          name: educator.first_name + " " + educator.last_name + " ID: " + educator.uniqueId
        }
    });

    let selectedEducators = this.state.nooraClass.educators.map((uniqueId)=> {
        const educator = Educators.findOne({ uniqueId: uniqueId });
        return {
          value: uniqueId,
          name: educator.first_name + " " + educator.last_name + " ID: " + educator.uniqueId
        }
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
          <div className="fields">
            <Form.Input
              type='number'
              key= 'total_patients'
              label= 'Total Patients'
              type= 'number'
              placeholder="Total Patients"
              value={ this.state.nooraClass.total_patients }
              onChange={ this._handleChange("total_patients") }
            />
            <Form.Input
              type='number'
              key= 'total_family_members'
              label= 'Total Family Members'
              type= 'number'
              placeholder="Total Family Members"
              value={ this.state.nooraClass.total_family_members }
              onChange={ this._handleChange("total_family_members") }
            />
          </div>

          <div className="fields">
            <div className="field">
              <label> Date of Class </label>
              <DatePicker
                className="right floated"
                selected= { dateOfClass }
                onChange={ this._onDateChange  }
                dateFormat="DD/MM/YYYY"
                />
            </div>

            <div className="field">
              <label> Start Time </label>
              <Timepicker
                value= { this.state.nooraClass.start_time }
                placeholder= 'Start Time'
                onChange={ this._handleChange("start_time") }
              />
            </div>
            <div className="field">
              <label> End Time </label>
              <Timepicker
                value= { this.state.nooraClass.end_time }
                placeholder= 'End Time'
                onChange={ this._handleChange("end_time") }
              />
            </div>
          </div>
          <Form.MultiSelectDropdown
            options={ educatorOptions }
            selected={ selectedEducators  }
            label="Add Educators"
            placeholder="Educators"
            onChange={ this._handleChange("educators") }
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

  _onDateChange( value ){
    this._handleChange("date")(value.format("YYYY-MM-DD"));
  },

  _saveClass(nooraClass) {
    const that = this;
    const showPopup = ( options, callback )=> {
      Meteor.setTimeout( ()=> {
        swal(options, callback);
      }, 100 );
    };

    const onSaveSuccess = function( nooraClass ){
      const text = nooraClass.name;
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
