'use strict'
import React from 'react';

const TimePicker = React.createClass({

  getDefaultProps() {
    return {
      onChange: function(){}
    };
  },

  componentDidMount() {
    $(this.picker).calendar({
      type: "time",
      onChange: this.props.onChange
    })
  },

  render() {
    console.log("Rendering");
    return (
      <div className="ui calendar" ref={(picker)=> this.picker = picker}>
        <div className="ui input left icon">
          <i className="time icon"></i>
          <input type="text" placeholder="Time"/>
        </div>
      </div>
    );
  }

});

export { TimePicker };
