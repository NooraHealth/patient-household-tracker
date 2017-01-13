
import { FlowRouter } from 'meteor/kadira:flow-router';
import React from 'react';
import { mount } from 'react-mounter';

import { MainLayout } from '../../ui/layout.jsx';
import { HomePage } from '../../ui/pages/Home.jsx';
import { SelectFacilityContainer } from '../../ui/containers/SelectFacilityContainer.jsx';
import { AddClassContainer } from '../../ui/containers/AddClassContainer.jsx';
import { BackButton } from '../../ui/components/Headers/BackButton.jsx';

FlowRouter.route('/', {
  action: function(){
    mount( MainLayout, {
      content: <HomePage key='homepage'/>
    });
  }
});

FlowRouter.route('/addClass', {
  name: "addClass",
  action: function( params ){
    mount( MainLayout, {
      nav_components: <BackButton key='back_button'/>,
      content: <AddClassContainer
        key='add_class_page'
        />
    });
  }
});
