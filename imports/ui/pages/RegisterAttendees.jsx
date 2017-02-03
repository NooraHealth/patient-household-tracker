
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
    mode: React.PropTypes.string,
    numAttendees: React.PropTypes.number,
    diagnoses: React.PropTypes.array,
    classDoc: React.PropTypes.object
  },

  defaultProps() {
    return {
      currentFacilityName: "",
      numAttendees: 0,
      loading: true,
      mode: "addNewAttendees",
      classDoc: {}
    }
  },

  getInitialState() {
    const nooraClass = new NooraClass(this.props.classDoc);
    return {
      loading: false,
      numRows:  nooraClass.attendees.size,
      nooraClass: nooraClass
    }
  },

  componentDidMount(){
    /* set default language for all attendees */
    if( this.props.mode == "editAttendees" ){
      console.log("MODE");
      console.log(this.props.mode);
      return;
    }
    this._addAttendees( this.props.numAttendees, this.state.nooraClass.attendees );
  },

  renderSingleRow( attendee, i ){
    const name = ( attendee )? attendee.name: '';
    const phone1 = ( attendee )? attendee.phone_1: '';
    const phone2 = ( attendee )? attendee.phone_2: '';
    const patientAttended = ( attendee )? attendee.patient_attended: false;
    const numCaregivers = ( attendee )? attendee.num_caregivers_attended: '';
    const language = ( attendee )? attendee.language: '';
    const diagnosis = ( attendee )? attendee.diagnosis: '';
    const selectedLanguage = { name: language, value: language };
    const languageOptions = this.props.supportedLanguages.map( function(language){
        return { name: language, value: language };
    });
    const diagnosisOptions = this.props.diagnoses.map( function(diagnosis){
        return { title: diagnosis };
    });
    return (
      <div>
      <br/>
      <div className="ui dividing header">
          Attendee { i+1 }
          { this.props.mode == "editAttendees" &&
            <button className="ui icon red button add-margin" onClick={ this._deleteAttendee.bind(this, i, attendee) }>
              <i className="trash icon"></i>
            </button>
          }
      </div>
      <br/>
      <div className="fields">
        <Form.Input
          key= { 'name--' + i }
          placeholder= "Name"
          inputClasses="four wide"
          value={ name }
          onChange={ this._handleChange(i, "name") }
        />
        <Form.Input
          type='tel'
          key= { 'phone1--' + i }
          placeholder="Phone One"
          inputClasses="four wide"
          value={ phone1 }
          onChange={ this._handleChange(i, "phone_1") }
        />
        <Form.Input
          type='tel'
          key= { 'phone2--' + i }
          placeholder="Phone Two"
          value={ phone2 }
          inputClasses="four wide"
          onChange={ this._handleChange(i, "phone_2") }
        />
        <Form.Checkbox
          key= { 'patient-attended--' + i }
          label="Patient Attended?"
          checked={ patientAttended }
          onChange={ this._handleChange(i, "patient_attended") }
        />
        <Form.Input
          type='number'
          key= { 'num-caregivers--' + i }
          inputClasses="four wide"
          placeholder="# Caregivers Attended"
          value={ numCaregivers }
          onChange={ this._handleChange(i, "num_caregivers_attended") }
        />
        <Form.Search
          key= { 'diagnosis---' + i }
          label="Diagnosis"
          onChange={ this._handleChange(i, "diagnosis") }
          source={ diagnosisOptions }
          value={ diagnosis }
        />
        <Form.Dropdown
          key= {'language-- ' + i }
          label="Language"
          style={ { width:"200px" } }
          onChange={ this._handleChange(i, "language") }
          options={ languageOptions }
          selected={ [{ value: language, name: language}] }
        />
      </div>
      </div>
    )
  },

  render() {
    const submitText = (this.props.mode == "editAttendees" )? "SAVE" : "REGISTER ATTENDEES";
    const attendees = this.state.nooraClass.attendees.toArray();
    const that = this;
    let rows = [];
    for( var i=0; i < this.state.numRows; i++ ){
      let key = "attendee" + i;
      // let attendee = this.state.nooraClass.attendees.get(i);
      rows.push(
        <div key={ key }>{ that.renderSingleRow(this.state.nooraClass.attendees.get(i) , i) }</div>
      );
    };

    const educatorsList = this.state.nooraClass.educators.map(function( educator ){
      let doc = Educators.findOne({ contact_salesforce_id: educator.contact_salesforce_id });
      return (
        <div className="ui blue label" key={ "educator--" + doc.uniqueId}>
          { doc.first_name } { doc.last_name }
          <div className="detail"> { doc.uniqueId } </div>
        </div>
      )
    });
    return (
      <Form onSubmit={ this._onSubmit } submitButtonContent={ submitText } disabled={ this.state.loading } >
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
        { this.props.mode == "editAttendees" &&
          <button className="ui labeled icon blue button" onClick={ this._addAttendees.bind(this, 1) }>
            Add Attendee <i className="large add user icon"></i>
          </button>
        }
      </Form>
    )
  },

  _handleChange(index, field) {
    return (value) => {
      let newValues = this.state.nooraClass.attendees.get(index);
      if( !newValues ){
        newValues = {};
      }
      newValues[field] = value;
      const list = this.state.nooraClass.attendees.set(index, newValues);
      const nooraClass = this.state.nooraClass.set("attendees", list);
      this.setState({ nooraClass: nooraClass })
    }
  },

  _addAttendees( number ){
    const language = this.state.nooraClass.majority_language;
    let attendees = this.state.nooraClass.attendees;
    for(var i = 0; i < number; i++){
      attendees = attendees.push( {'language': language });
    }
    const nooraClass = this.state.nooraClass.set("attendees", attendees);
    const numRows = this.state.numRows + number
    this.setState({ nooraClass: nooraClass })
    this.setState({ "numRows": numRows });
  },

  _deleteAttendee( index, attendee ){
    const attendees = this.state.nooraClass.attendees.delete(index);
    const deleted = this.state.nooraClass.deleted_attendees.push(attendee);
    let nooraClass = this.state.nooraClass.set("attendees", attendees);
    nooraClass = nooraClass.set("deleted_attendees", deleted);
    this.setState({ nooraClass: nooraClass })
    this.setState({ "numRows": this.state.numRows-1 });
  },

  _onSubmit() {
    const that = this;
    try {
      swal({
        type: "info",
        closeOnConfirm: true,
        showCancelButton: true,
        text: "Are you sure you want to register these attendees?",
        title: "Confirm"
      }, function( isConfirm ) {
        if( !isConfirm ) {
          that.setState({ loading: false });
          return;
        }
        that.setState({ loading: true });
        that._registerAttendees()
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

  _showPopup( options, callback ) {
    Meteor.setTimeout( ()=> {
      swal(options, callback);
    }, 100 );
  },

  _registerAttendees() {
    const that = this;

    const onSaveSuccess = function( nooraClass ){
      const text = nooraClass.name + ": " + nooraClass.attendees.length + " attendees";
      that._showPopup({
        type: "success",
        title: "Attendees Saved Successfully",
        text: text
      });
      FlowRouter.go("home");
    };

    const onSaveError = function(error) {
      /* TODO: render according to whether loading */
      that.setState({ loading: false });
      that._showPopup({
        type: "error",
        text: error,
        title: "Error registering attendees"
      });
    }
    this.state.nooraClass.save().then( results => onSaveSuccess(results), error => onSaveError(error))
  }

});

export { RegisterAttendeesPage };
