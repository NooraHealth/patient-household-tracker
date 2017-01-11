
'use strict';

import React from 'react';

var ListItem = React.createClass({

  propTypes: {
    title: React.PropTypes.string,
    value: React.PropTypes.string,
    icon: React.PropTypes.string,
    description: React.PropTypes.string
  },

  defaultProps() {
    return {
      title: "",
      value: "",
      icon: "",
      description: ""
    }
  },

  _handleClick(e){
    this.props.onSelect(this.props.value);
  },

  render(){
    var { title, after, onSelect, icon, description } = this.props;
    return (
      <div className="ui segment item"
        onClick={ this._handleClick }
      >
        <i className={ icon }></i>
        <div className="content">
          <div className="header">
            { title }
          </div>
          <div className="description">
            { description }
          </div>
        </div>
      </div>
    );
  }
});

export { ListItem };
