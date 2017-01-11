import React, { PropTypes } from 'react'
import Immutable from 'immutable';

var MultiSelectDropdown = React.createClass({

  propTypes: {
    placeholder: React.PropTypes.string,
    options: React.PropTypes.arrayOf(( options, index )=> {
      return new SimpleSchema({
        value: { type:String },
        name: { type:String }
      }).validate(options[index]);
    }),
    selected: React.PropTypes.arrayOf(( options, index )=> {
      return new SimpleSchema({
        value: { type:String },
        name: { type:String }
      }).validate(options[index]);
    }),
    onChange: React.PropTypes.func
  },

  defaultProps(){
    return {
      placeholder: "",
      onChange: function(){},
      options: [],
      selected: []
    }
  },

  componentDidMount() {
    const onChange = this.props.onChange;
    $(this.dropdown).dropdown({
      onChange: function(value, text, selectedItem) {
        onChange(value);
      }
    });
    const values = this._getValues(this.props.selected);
    $(this.dropdown).dropdown("set exactly", values);
  },

  componentDidUpdate(prevProps, prevState) {
    if( JSON.stringify(this.props.selected) !== JSON.stringify(prevProps.selected)){
      const values = this._getValues(this.props.selected);
      $(this.dropdown).dropdown("set exactly", values);
    }
  },

  render(){
    const optionElems = this.props.options.map(function(option, i){
      const key = "operation-" + option.value;
      return <option value={option.value} key={key}>{option.name}</option>
    });

    return (
      <div>
        <div className="ui sub header">{ this.props.label }</div>
        <select
          className="ui fluid multiple search normal selection dropdown"
          ref={ (elem)=> this.dropdown = elem }
          multiple=""
          >
          <option value="">{ this.props.placeholder }</option>
          { optionElems }
        </select>
      </div>
    );
  },

  _getValues( options ){
    return options.map((selected)=>{ return selected.value });
  }

});

export { MultiSelectDropdown };
