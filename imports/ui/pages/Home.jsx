'use strict';

//import { React } from 'react';
import React from 'react';

const HomePage = React.createClass({

  propTypes: {
    currentFacilityName: React.PropTypes.string
  },

  defaultProps() {
    return {
      currentFacilityName: ""
    }
  },

  render(){
    return (
      <div>
        <p><a
          href="/addClass"
          className="fluid ui blue button"
          > Add Class
        </a></p>

        <p><a
          href="/selectClass/addNew"
          className="fluid ui blue button"
          > Add Attendees
        </a></p>

        <p><a
          href="/selectClass/edit"
          className="fluid ui blue button"
          > Edit Attendees
        </a></p>
      </div>
    )
  }
});

export { HomePage };
