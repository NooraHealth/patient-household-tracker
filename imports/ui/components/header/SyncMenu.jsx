
'use strict';

import React from 'react';

var SyncMenu = React.createClass({

  getInitialState() {
    return {
      loading: false
    };
  },

  componentDidMount() {
    $(".dropdown").dropdown()
  },

  render: function(){
    return (
      <div ref={ (menu)=>{this.menu = menu; }}className="ui text menu">
        { this.state.loading ? <div className="ui active inline loader"></div> : <div></div> }
        <div className="ui right dropdown item">
          SYNC
          <i className="dropdown icon"></i>
          <div className="menu">
            <div className="item" onClick={ this._fetchEducators }>Import Educators</div>
            <div className="item" onClick={ this._fetchFacilities }>Import Facilities</div>
            <div className="item" onClick={ this._fetchConditionOperations }>Import Condition Operations</div>
          </div>
        </div>
      </div>
    );
  },

  _fetchConditionOperations(){
    this.setState({ loading: true });
    Meteor.call("syncConditionOperations", (err, results)=>{
      this.setState({ loading: false });
    });
  },

  _fetchEducators(){
    this.setState({ loading: true });
    Meteor.call("syncEducators", (err, results)=>{
      this.setState({ loading: false });
    });
  },
  
  _fetchFacilities(){
    this.setState({ loading: true });
    Meteor.call("syncFacilities", (err, results)=>{
      this.setState({ loading: false });
    });
  }
});

export { SyncMenu };
