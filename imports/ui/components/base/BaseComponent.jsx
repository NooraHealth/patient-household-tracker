'use strict';

class BaseComponent extends React.Component {
  _bind(...methods){
    methods.forEach( ( method )=> this[method] = this[method].bind(this));
  }
}

this.BaseComponent = BaseComponent
