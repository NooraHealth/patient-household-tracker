
  'use strict';

import React from 'react';
import Immutable from 'immutable'
import { Form } from '../components/form/base/Form.jsx';
import { Educators } from '../../api/collections/educators.coffee';
import { NooraClass } from '../../api/immutables/NooraClass.coffee';
import { SelectFacilityContainer } from '../containers/SelectFacilityContainer.jsx';
import DatePicker from 'react-datepicker';

var AddAttendeesPage = React.createClass({

  propTypes: {
    currentFacilityName: React.PropTypes.string,
    loading: React.PropTypes.bool,
    classes: React.PropTypes.array
  },

  defaultProps() {
    return {
      currentFacilityName: "",
      classes: [],
      attendees: null,
      loading: true
    }
  },

  getInitialState() {
    return {
      loading: false,
      classSelected: false,
      attendees: this.props.attendees
    }
  },

  renderSelectClassForm(){
    const submitText = "SELECT CLASS"
    const classOptions = this.props.classes.map(function(nooraClass) {
      return { title: nooraClass.name };
    });

    return (
      <div>
        <Form onSubmit={ this._onSelectClass } submitButtonContent={ submitText } disabled={ this.state.loading } >
          <SelectFacilityContainer/>
          <Form.Search
            key= 'class_name'
            placeholder="Select Class"
            icon="search icon"
            value={ this.state.attendees.class_name }
            onChange={ this._handleChange("class_name") }
            source={ classOptions }
          />
          <Form.Input
            type='number'
            key= 'total_number_attended'
            label="Total Number Attended"
            placeholder="Total Number Attended"
            value={ this.state.attendees.num_attendees }
            onChange={ this._handleChange("num_attendees") }
          />
        </Form>
      </div>
    )
  },

  renderRegisterAttendeesForm(){
    const submitText = "REGISTER ATTENDEES";
    var rows = [];
    for (var i = 0; i < this.state.attendees.num_attendees; i++) {
      let key = "attendee" + i;
      rows.push(
        <div key={ key } className="row">{ this.renderSingleRow(this.state.attendees[i]) }</div>
      );
    }

    return (
      <div>
        <Form onSubmit={ this._registerAttendees } submitButtonContent={ submitText } disabled={ this.state.loading } >
          <div className="ui grid"> { rows } </div>
        </Form>
      </div>
    )
  },

  renderSingleRow( attendee ){
    const name = ( attendee )? attendee.name: '';
    return (
      <Form.Input
        key= 'name'
        className="two wide column"
        placeholder="Name"
        value={ name }
        onChange={ this._handleChange("total_patients") }
      />
    )
  },

  render() {
    if( this.state.classSelected ){
      return ( <div> { this.renderRegisterAttendeesForm() } </div>);
    } else {
      console.log("Rendering class form");
      return ( <div> { this.renderSelectClassForm() } </div>);
    }
  },

  _onSelectClass(){
    this.setState({ classSelected: true });
  },

  _registerAttendees(){
    console.log("REGISTERING");
  },

  _handleChange(field) {
    return (value) => {
      const attendees = this.state.attendees.set(field, value);
      this.setState({ attendees: attendees })
    }
  }

});

export { AddAttendeesPage };
