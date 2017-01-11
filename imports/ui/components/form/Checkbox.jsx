
import React, { PropTypes } from 'react'

var Checkbox = React.createClass({

  propTypes: {
    label: React.PropTypes.string,
    value: React.PropTypes.string,
    onChange: React.PropTypes.func,
    checked: React.PropTypes.bool
  },

  defaultProps(){
    return {
      label: "",
      value: "",
      onChange: function(){},
      checked: false
    }
  },

  componentDidMount() {
    const onChange = this.props.onChange;
    $(this.checkbox).checkbox({
      onChange: ()=> {
        const checked = $(this.checkbox).checkbox("is checked");
        onChange( this.props.value, checked );
      }
    });
    let behavior = ( this.props.checked )? "set checked": "set unchecked";
    $(this.checkbox).checkbox(behavior);
  },

  componentDidUpdate(prevProps, prevState) {
    if( this.props.checked !== prevProps.checked ){
      let behavior = ( this.props.checked )? "set checked": "set unchecked";
      $(this.checkbox).checkbox(behavior);
    }
  },

  render(){
    var { label, onChange, ...inputProps } = this.props;
    return (
      <div className="ui left floated checkbox" ref={ (checkbox)=> this.checkbox = checkbox }>
        <input type="checkbox" name="activation"/>
        <label>{ label }</label>
      </div>
    );
  }
});

module.exports.Checkbox = Checkbox;
