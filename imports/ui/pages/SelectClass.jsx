
'use strict';

import React from 'react';
import { Form } from '../components/form/base/Form.jsx';
import { Classes } from '../../api/collections/classes.coffee';
import { NooraClass } from '../../api/immutables/NooraClass.coffee';
import { SelectFacilityContainer } from '../containers/SelectFacilityContainer.jsx';

var SelectClassPage = React.createClass({

  propTypes: {
    currentFacilityName: React.PropTypes.string,
    loading: React.PropTypes.bool,
    editMode: React.PropTypes.bool,
    classes: React.PropTypes.array
  },

  defaultProps() {
    return {
      currentFacilityName: "",
      classes: [],
      loading: true
    }
  },

  getInitialState() {
    return {
      loading: false,
      class_name: '',
      num_attendees: ''
    }
  },

  render() {
    const submitText = "SELECT CLASS"
    const classOptions = this.props.classes.map(function(nooraClass) {
      return { value: nooraClass.name, name: nooraClass.name };
    });

    return (
      <div>
        <Form onSubmit={ this._onSelectClass } submitButtonContent={ submitText } disabled={ this.state.loading } >
          <SelectFacilityContainer/>
          <Form.Dropdown
            key= 'class_name'
            label="Select Class"
            icon="search icon"
            onChange={ this._handleChange("class_name") }
            options={ classOptions }
            selected={ [{ value: this.state.class_name, name: this.state.class_name}] }
          />
          { !this.props.editMode &&
              <Form.Input
              type='number'
              key= 'total_number_attended'
              label="Total Number Households"
              value={ this.state.num_attendees }
              onChange={ this._handleChange("num_attendees") }
            />
          }
        </Form>
      </div>
    )
  },

  _onSelectClass(){
    FlowRouter.go("registerAttendees", {
      className: this.state.class_name
    }, {
      numAttendees: this.state.num_attendees,
      editMode: this.props.editMode
    });
  },

  _handleChange(field) {
    return (value) => {
      let obj = {};
      obj[field] = value;
      this.setState( obj );
    }
  }
});

export { SelectClassPage };
