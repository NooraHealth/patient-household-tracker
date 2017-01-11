
var React = require('react');
var PropTypes = React.PropTypes;

var Modal  = React.createClass({

  render: function() {
    var { title } = this.props;
    return (
      <div class="ui modal">
        <i class="close icon"></i>
        <div class="header">
          { title }
        </div>
        <div class="actions">
          <div class="ui cancel button">Cancel</div>
          <div class="ui approve button">OK</div>
        </div>
      </div>
    );
  }

});

module.exports = Modal ;
