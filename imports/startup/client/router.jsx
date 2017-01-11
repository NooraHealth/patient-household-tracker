
import { FlowRouter } from 'meteor/kadira:flow-router';
import React from 'react';
import { mount } from 'react-mounter';

import { MainLayout } from '../../ui/layout.jsx';
import { HomePage } from '../../ui/pages/Home.jsx';
import { AddEducatorPage } from '../../ui/pages/AddEducator.jsx';
import { SelectFacilityContainer } from '../../ui/containers/SelectFacilityContainer.jsx';
import { SearchEducatorsContainer } from '../../ui/containers/SearchEducatorsContainer.jsx';
import { AddEducatorContainer } from '../../ui/containers/AddEducatorContainer.jsx';

import { BackButton } from '../../ui/components/Headers/BackButton.jsx';
import { SyncMenu } from '../../ui/components/Headers/SyncMenu.jsx';

FlowRouter.route('/', {
  action: function(){
    mount( MainLayout, {
      nav_components: <SyncMenu key='sync_menu'/>,
      content: <HomePage key='homepage'/>
    });
  }
});

FlowRouter.route('/addEducator/:educatorToEditId?', {
  name: "addEducator",
  action: function( params ){
    mount( MainLayout, {
      nav_components: <BackButton key='back_button'/>,
      content: <AddEducatorContainer
        key='add_educator_page'
        educatorToEditId= {params.educatorToEditId}
        />
    });
  }
});

FlowRouter.route('/searchEducators', {
  action: function(){
    currentFacilityId = Session.get("current_facility_id");
    currentFacilityName = Session.get("current_facility_name");
    mount( MainLayout, {
      nav_components: <BackButton key='back_button'/>,
      content: <SearchEducatorsContainer/>
    });
  }
});
