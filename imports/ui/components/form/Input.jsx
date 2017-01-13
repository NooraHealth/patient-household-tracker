
'use strict';

import React from 'react';

var Input = React.createClass({

  propTypes: {
    icon: React.PropTypes.string,
    onChange: React.PropTypes.func
  },

  defaultProps() {
    return {
      value: "",
      icon: "",
      onChange: null
    }
  },

  _handleChange(onChange, e) {
    if(e.target && e.target.value !== undefined) {
      onChange(e.target.value);
    }
  },

  render(){
    var { title, icon, value, onChange, ...inputProps } = this.props;
    return (
      <div className="ui fluid left icon input" >
        { this.getInputPrefix() }
        <input
          { ...inputProps }
          value={ value }
          onInput={ this._handleChange.bind(this, onChange) }
        />
      </div>
    );
  },

  getInputPrefix() {
    if( this.props.icon ){
      return <i className={ icon }></i>;
    } else {
      return (
        <div className="ui label">
            { this.props.label }
        </div>
      )
    }
  }

});

export { Input };
