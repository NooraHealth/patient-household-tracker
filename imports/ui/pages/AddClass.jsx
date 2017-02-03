'use strict';

import React from 'react';
import moment from 'moment';
import Immutable from 'immutable'
import { Form } from '../components/form/base/Form.jsx';
import { Educators } from '../../api/collections/educators.coffee';
import { ConditionOperations } from '../../api/collections/condition_operations.coffee';
import { NooraClass } from '../../api/immutables/NooraClass.coffee';
import { getHour } from '../../api/utils.coffee';
import { getMinute } from '../../api/utils.coffee';
import { getDateTime } from '../../api/utils.coffee';
import { SelectFacilityContainer } from '../containers/SelectFacilityContainer.jsx';
import DatePicker from 'react-datepicker';

var AddClassPage = React.createClass({

  propTypes: {
    currentFacilityName: React.PropTypes.string,
    loading: React.PropTypes.bool,
    availableEducators: React.PropTypes.array,
    conditionOperations: React.PropTypes.array,
    locations: React.PropTypes.array,
    classDoc: React.PropTypes.object
  },

  defaultProps() {
    return {
      currentFacilityName: "",
      locations: [],
      conditionOperations: [],
      availableEducators: [],
      classDoc: {},
      loading: true
    }
  },

  getInitialState() {
    let nooraClass = new NooraClass(this.props.classDoc);
    nooraClass = nooraClass.set("facility_name", this.props.currentFacilityName);
    return {
      loading: false,
      nooraClass: nooraClass
    }
  },

  componentDidUpdate(prevProps, prevState) {
    if( this.props.currentFacilityName !== prevProps.currentFacilityName){
      let nooraClass = this._clearEducators();
      nooraClass = nooraClass.set("condition_operation_salesforce_id", '');
      nooraClass = nooraClass.set("facility_name", this.props.currentFacilityName );
      this.setState({ nooraClass: nooraClass });
      console.log("Cleared!!");
      console.log(this.state.nooraClass.toJS());
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

    let operationOptions = this.props.conditionOperations.map(( op )=> {
        return {
          value: op.salesforce_id,
          name: op.name
        }
    });

    const operation = ConditionOperations.findOne({ salesforce_id: this.state.nooraClass.condition_operation_salesforce_id });
    let selectedOption = {
      name: (operation)? operation.name: "",
      value: (operation)? operation.salesforce_id: ""
    }

    let educatorOptions = this.props.availableEducators.map((educator)=> {
        return {
          value: educator.contact_salesforce_id,
          name: educator.first_name + " " + educator.last_name + " ID: " + educator.uniqueId
        }
    });

    let selectedEducators = this.state.nooraClass.educators.toArray().map((educator)=> {
        const doc = Educators.findOne({ contact_salesforce_id: educator.contact_salesforce_id });
        return {
          value: doc.contact_salesforce_id,
          name: doc.first_name + " " + doc.last_name + " ID: " + doc.uniqueId
        }
    });

    let languageOptions = this.props.supportedLanguages.map( function(language){
        return { value: language, name: language };
    });

    return (
      <div>
        <Form onSubmit={ this._onSubmit } submitButtonContent={ submitText } disabled={ this.state.loading } >
          <SelectFacilityContainer/>
          <Form.Dropdown
            options={ operationOptions }
            selected={ [selectedOption] }
            label="Condition Operation"
            onChange={ this._handleChange( "condition_operation_salesforce_id") }
          />
          <Form.Search
            key= 'class_location'
            label="Location"
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
            <Form.Dropdown
              key="majority_language"
              label="Majority Language"
              onChange={ this._handleChange("majority_language") }
              options={ languageOptions }
              selected={[
                { value: this.state.nooraClass.majority_language,
                  name: this.state.nooraClass.majority_language
                }]}
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
              <Form.TimePicker
                value= { this.state.nooraClass.start_time }
                placeholder= 'Start Time'
                showSecond={ false }
                onChange={ this._handleChange("start_time") }
              />
            </div>
            <div className="field">
              <label> End Time </label>
              <Form.TimePicker
                value= { this.state.nooraClass.end_time }
                placeholder= 'End Time'
                showSecond={ false }
                onChange={ this._handleChange("end_time") }
              />
            </div>
          </div>
          <Form.Dropdown
            options={ educatorOptions }
            selected={ selectedEducators  }
            multiple={ true }
            label="Add Educators"
            placeholder="Educators"
            onChange={ this._onEducatorChange }
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

  _onEducatorChange( educatorSalesforceIds ){
    const currentEducators = this.state.nooraClass.educators;
    const oldIds = currentEducators.toArray().map((educator)=>{ return educator.contact_salesforce_id });
    var newList = Immutable.List();
    let deleted = this.state.nooraClass.deleted_educators;
    let leftOverIds = educatorSalesforceIds;
    for (var i = 0; i < oldIds.length; i++) {
      let indexOfId = educatorSalesforceIds.indexOf(oldIds[i]);
      //If the oldId exists in the new list
      if( indexOfId != -1 ){
        //Push onto new list
        newList = newList.push( this.state.nooraClass.educators.get(i));
        leftOverIds.splice(indexOfId, 1);
      } else {
        deleted = deleted.push(currentEducators.get(i));
      }
    }
    leftOverIds.forEach(function( id ){
      newList = newList.push({ contact_salesforce_id: id });
    });
    const nooraClass = this.state.nooraClass.set("deleted_educators", deleted);
    this.setState({ nooraClass: nooraClass });
    this._handleChange("educators")(newList);
  },

  _clearEducators(){
    let educators = this.state.nooraClass.educators;
    let deleted = this.state.nooraClass.deleted_educators;
    for (var i = 0; i < educators.size; i++) {
      deleted = deleted.push(educators.get(i));
    }
    const cleared = educators.clear();
    let nooraClass = this.state.nooraClass.set("educators", cleared);
    return nooraClass.set("deleted_educators", deleted);
  },

  _onDateChange( value ){
    this._handleChange("date")(value.format("YYYY-MM-DD"));
  },

  _onTimeChange( field, value ){
    this._handleChange(field)(moment(value).format("HH:mm"));
  },

  _saveClass() {
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
      FlowRouter.go("home");
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
