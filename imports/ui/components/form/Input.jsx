
'use strict';

import React from 'react';

var Input = React.createClass({

  propTypes: {
    value: React.PropTypes.string,
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
        <i className={ icon }></i>
        <input
          { ...inputProps }
          value={ value }
          onInput={ this._handleChange.bind(this, onChange) }
        />
      </div>
    );
  }
});

export { Input };
