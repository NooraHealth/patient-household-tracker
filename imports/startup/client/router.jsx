
import { FlowRouter } from 'meteor/kadira:flow-router';
import React from 'react';
import { mount } from 'react-mounter';

import { MainLayout } from '../../ui/layout.jsx';
import { HomePage } from '../../ui/pages/Home.jsx';
import { SelectFacilityContainer } from '../../ui/containers/SelectFacilityContainer.jsx';
import { BackButton } from '../../ui/components/Headers/BackButton.jsx';

FlowRouter.route('/', {
  action: function(){
    mount( MainLayout, {
      content: <HomePage key='homepage'/>
    });
  }
});
