
import React, { PropTypes } from 'react';
import DatePicker from 'react-datepicker';
import { MultiSelectDropdown } from '../form/MultiSelectDropdown.jsx';
import { Checkbox } from '../form/Checkbox.jsx';

const SelectConditionOperations  = React.createClass({
  propTypes: {
    options: React.PropTypes.arrayOf(( operations, index )=> {
      return new SimpleSchema({
        id: { type:String },
        name: { type:String },
        is_active: { type: Boolean },
        date_started: { type: String },
        operation_salesforce_id: { type: String, optional: true },
        role_salesforce_id: { type: String, optional: true}
      }).validate(operations[index]);
    }),
    selected: React.PropTypes.arrayOf(( operations, index )=> {
      return new SimpleSchema({
        id: { type:String },
        name: { type:String },
        is_active: { type: Boolean },
        operation_salesforce_id: { type: String, optional: true },
        date_started: { type: String },
        role_salesforce_id: { type: String, optional: true }
      }).validate(operations[index]);
    }),
    onSelectionChange: React.PropTypes.func,
    onActivationChange: React.PropTypes.func
  },

  defaultProps() {
    return {
      options: [],
      selected: [],
      onSelectionChange: function(){},
      onActivationChange: function(){}
    }
  },

  render () {
    let options = this.props.options.map((option)=> {
        return {
          value: option.id,
          name: option.name
        }
    });
    let selected = this.props.selected.map((option)=> {
        return {
          value: option.id,
          name: option.name
        }
    });

    let selectedOperationsComponents = [];
    for(let i= 0; i < this.props.selected.length; i++){
      let isActive = this.props.selected[i].is_active;
      let id = this.props.selected[i].id;
      let name = this.props.selected[i].name;
      let dateStarted = moment(this.props.selected[i].date_started);
      selectedOperationsComponents.push(
        <div key={ id } className="ui segment stackable grid item">
          <h4 className="four wide column">{ name }</h4>
          <div className="six wide column">
            <label className="center floated"> Date Started As Educator </label>
            <DatePicker
              className="right floated"
              selected= { dateStarted }
              onChange={ this._onDateChange.bind(this, id )  }
              dateFormat="DD/MM/YYYY"
              />
          </div>
          <div className="six wide column">
            <Checkbox
              label='Is Active'
              onChange={ this.props.onActivationChange }
              value={ id }
              checked={ isActive }
              />
          </div>
        </div>
      );
    }

    return (
      <div>
        <MultiSelectDropdown
          options={ options }
          selected={ selected  }
          label="Add Condition Operations"
          placeholder="Condition Operations"
          onChange={ this._onOperationSelectionChange }
          />
        <div className="ui segments middle aligned selection list">
          { selectedOperationsComponents }
        </div>
      </div>
    )
  },

  _onOperationSelectionChange( ids ){
    let optionsSelected = [];
    for (var i = 0; i < this.props.options.length; i++) {
      if ( ids.indexOf(this.props.options[i].id) !== -1 ) {
        optionsSelected.push(this.props.options[i]);
      }
    }
    this.props.onSelectionChange( optionsSelected );
  },

  _onDateChange( value, moment ){
    this.props.onDateChange(value, moment.format("YYYY-MM-DD"));
  }


});

export { SelectConditionOperations };
