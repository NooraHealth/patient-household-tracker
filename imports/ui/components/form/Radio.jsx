'use strict';

var RadioGroup = React.createClass({
  mixins: [ GetValueLink ],

  propTypes: {
    options: React.PropTypes.array,
    value: React.PropTypes.string,
    onChange: React.PropTypes.func,
    valueLink: React.PropTypes.shape({
      value: React.PropTypes.string.isRequired,
      requestChange: React.PropTypes.func.isRequired
    }),
    children: React.PropTypes.oneOfType([
      React.PropTypes.instanceOf(Radio),
      React.PropTypes.arrayOf(React.PropTypes.instanceOf(Radio))
    ])
  },

  defaultProps(){
    return {
      options: [],
      value: "",
      onChange: function() {},
      valueLink: null
    }
  },

  getInitialState(){ return {} },

  handleChange( i , event ){
    this._getValueLink(this.props).requestChange(this.refs['radio-'+i].props.option.value);
  },

  componentWillReceiveProps(nextProps) {
    var currentValueLink = this._getValueLink(this.props),
        nextValueLink = this._getValueLink(nextProps);
    
    if (currentValueLink.value !== nextValueLink.value) {
      var node = jQuery(this.getDOMNode());
      node.val(nextValueLink.value);
      node.change();
    }
  },

  render(){
    let that = this
    let options = this.props.options.map( function( option, i ){
      let checked = false;
      let ref = 'radio-' + i;
      if(option.value == that._getValueLink(that.props).value){
        checked = true;
      } 

      return < Form.RadioGroup.Radio
        key={ ref }
        option={ option }
        ref={ ref }
        checked= { checked }
        onChange={ that.handleChange.bind(that, i) }
      />
    });

    return (
      <div>
        { options }
      </div>
  
    )
  }
});

var Radio = React.createClass({
  propTypes: {
    option: React.PropTypes.shape({
      title: React.PropTypes.string,
      value: React.PropTypes.string
    }),
    checked: React.PropTypes.bool.isRequired,
    onChange: React.PropTypes.func
  },

  defaultProps(){
    return {
      option: { title: "", value: "" },
      checked: false,
      onChange: function() { return null }
    } 
  },

  render(){
    var { option, checked, onChange } = this.props;
    return (
      <label className="label-radio item-content">
        <input type="radio" onChange={ onChange } checked={ checked } />
        <div className="item-media">
          <i className="icon icon-form-radio"></i>
        </div>
        <div className="item-inner">
          <div className="item-title">{ option.title }</div>
        </div>
      </label>
    );
  }
});

this.Form.RadioGroup = RadioGroup
this.Form.RadioGroup.Radio = Radio
