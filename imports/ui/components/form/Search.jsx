
'use strict';

import React from 'react';

var Search = React.createClass({

  propTypes: {
    value: React.PropTypes.string,
    label: React.PropTypes.string,
    icon: React.PropTypes.string,
    onChange: React.PropTypes.func,
    source: React.PropTypes.array
  },

  defaultProps() {
    return {
      value: "",
      icon: "",
      onChange: function(){}
    }
  },

  componentDidMount() {
    const changeInputValue = (function(e) {
      const activeResult = $(this.search).find(".result.active");
      const text = $(this.search).find(".result.active").text();
      const acceptedKeyCodes = [ 13, 40, 38 ];
      if(
        acceptedKeyCodes.indexOf(e.keyCode) != -1 &&
        activeResult.length == 1 &&
        text != this.props.value ){
          this.props.onChange( text );
        }
    }).bind(this);

    $(this.input).keyup(changeInputValue);
    this._initializeSearch();
  },

  componentDidUpdate( prevProps, prevState ) {
    console.log("Component updated!!");
    console.log(prevProps.value);
    console.log(this.props.value);
    const shouldUpdateSearch = this.props.source !== null &&
                        prevProps.source !== null &&
                        JSON.stringify( this.props.source ) !== JSON.stringify(prevProps.source);
    if(shouldUpdateSearch){
      console.log("initializing the search");
      this._initializeSearch()
    }
  },

  _initializeSearch(){
    $(this.search)
      .search({
        source: this.props.source,
        searchFields: [
          'title'
        ],
        searchFullText: false,
        minCharacters: 0
      });
    $(this.search).search("clear cache");
  },

  handleClick( onChange, e ){
    const onResultClicked = function(e) {
      let text = $(e.target).text();
      onChange( text );
    };

    $(this.search).find(".result").click(onResultClicked);
  },

  handleChange( onChange, e ){
    console.log("HANDLING CHANGE");
    if(e.target && e.target.value !== undefined ) {
      onChange(e.target.value);
    }
  },

  handleFocus(){
    $(this.search).search("search local", "");
  },

  render(){
    var { label, icon, value, onChange, source, loading, ...inputProps } = this.props;
    console.log("Rendering value " + value);
    const getInputClasses = function() {
      const defaultClasses = "ui fluid left ";
      const type = (icon)? "icon": "labeled";
      return defaultClasses + type + " input";
    }
    const getInputPrefix = function() {
      if( icon ){
        return <i className={icon}></i>;
      } else {
        return (
          <div className="ui label">
              { label }
          </div>
        )
      }
    }
    return (
      <div
        className="ui search"
        ref={ (search)=> this.search = search }
        >
        <div className={ getInputClasses() }>
          { getInputPrefix() }
          <input
            { ...inputProps }
            className="prompt"
            type="text"
            value={ value }
            onBlur={ this.handleClick.bind(this, onChange) }
            onFocus={ this.handleFocus }
            onChange={ this.handleChange.bind(this, onChange) }
            ref={ (input) => this.input = input }
            />
        </div>
        <div className="results" ref={(results)=> this.results = results}></div>
      </div>
    );
  }
});

export { Search };
