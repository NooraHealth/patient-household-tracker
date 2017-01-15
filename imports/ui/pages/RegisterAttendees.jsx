
  'use strict';

import React from 'react';
import Immutable from 'immutable'
import { Form } from '../components/form/base/Form.jsx';
import { Educators } from '../../api/collections/educators.coffee';
import { Classes } from '../../api/collections/classes.coffee';
import { NooraClass } from '../../api/immutables/NooraClass.coffee';
import { SelectFacilityContainer } from '../containers/SelectFacilityContainer.jsx';
import DatePicker from 'react-datepicker';

var RegisterAttendeesPage = React.createClass({

  propTypes: {
    currentFacilityName: React.PropTypes.string,
    loading: React.PropTypes.bool,
    numAttendees: React.PropTypes.number,
    classDoc: React.PropTypes.object
  },

  defaultProps() {
    return {
      currentFacilityName: "",
      numAttendees: 0,
      loading: true,
      classDoc: {}
    }
  },

  getInitialState() {
    let nooraClass = new NooraClass(this.props.classDoc);
    console.log(nooraClass);
    return {
      loading: false,
      nooraClass: nooraClass
    }
  },

  renderSingleRow( attendee, i ){
    const name = ( attendee )? attendee.name: '';
    const phone1 = ( attendee )? attendee.phone1: '';
    const patientAttended = ( attendee )? attendee.patient_attended: 'false';
    const numCaregivers = ( attendee )? attendee.num_caregivers_attended: '';
    const language = ( attendee )? attendee.language: '';
    const selectedLanguage = { name: language, value: language };
    const languageOptions = [
      { name: "English", value: "English" },
      { name: "Hindi", value: "Hindi" },
      { name: "Kannada", value: "Kannada" },
    ];
    return (
      <div className="fields">
        <Form.Input
          key= { 'name--' + i }
          label= "Name"
          value={ name }
          onChange={ this._handleChange("total_patients") }
        />
        <Form.Input
          type='tel'
          key= { 'phone1--' + i }
          label="Phone One"
          value={ phone1 }
          onChange={ this._handleChange("phone") }
        />
        <Form.Input
          type='tel'
          key= { 'phone2--' + i }
          label="Phone Two"
          value={ phone1 }
          onChange={ this._handleChange("phone_2") }
        />
        <Form.Input
          type='number'
          key= { 'num-caregivers--' + i }
          label="# Caregivers Attended"
          value={ numCaregivers }
          onChange={ this._handleChange("num_caregivers_attended") }
        />
        <Form.Checkbox
          key= { 'patient-attended--' + i }
          label="Patient Attended?"
          value={ patientAttended }
          onChange={ this._handleChange("patient_attended") }
        />
      </div>
    )
  },

  render() {
    const submitText = "REGISTER ATTENDEES";
    var rows = [];
    for (var i = 0; i < this.props.numAttendees; i++) {
      let key = "attendee" + i;
      console.log(key);
      rows.push(
        <div key={ key }>{ this.renderSingleRow(this.state.nooraClass.attendees[i], i) }</div>
      );
    }
    const educatorsList = this.state.nooraClass.educators.map(function( uniqueId ){
      let doc = Educators.findOne({ uniqueId: uniqueId });
      return (
        <div className="ui blue label" key={ "educator--" + uniqueId}>
          { doc.first_name } { doc.last_name }
          <div className="detail"> { doc.uniqueId } </div>
        </div>
      )
    });
    return (
      <div>
      <Form onSubmit={ this._registerAttendees } submitButtonContent={ submitText } disabled={ this.state.loading } >
        <div className="fields">
          <div className="field">
            <div className="ui yellow label">
              { this.props.currentFacilityName }
              <div className="detail">{ this.state.nooraClass.location } </div>
            </div>
          </div>
          <div className="field"> { educatorsList } </div>
        </div>

        { rows }
      </Form>
      </div>
    )
  },

  _onSelectClass(){
    const doc = Classes.findOne({ name: this.state.nooraClass.name });
    const selected = new NooraClass(doc);
    this.setState({ nooraClass: selected, nooraClass: true });
  },

  _handleChange(field) {
    return (value) => {
      const attendees = this.state.nooraClass.set(field, value);
      this.setState({ attendees: attendees })
    }
  },

  _registerAttendees() {
    const that = this;
    const showPopup = ( options, callback )=> {
      Meteor.setTimeout( ()=> {
        swal(options, callback);
      }, 100 );
    };

    const onSaveSuccess = function( listOfAttendees ){
      const text = listOfAttendees.class_name + ": " +listOfAttendees.num_attendees + " attendees";
      showPopup({
        type: "success",
        title: "Attendees Saved Successfully",
        text: text
      });
    };

    const onSaveError = function(error) {
      /* TODO: render according to whether loading */
      that.setState({ loading: false });
      showPopup({
        type: "error",
        text: error.message,
        title: "Error inserting registering attendees"
      });
    }
    this.state.attendees.save().then( results => onSaveSuccess(results), error => onSaveError(error))
  }

});

export { RegisterAttendeesPage };
