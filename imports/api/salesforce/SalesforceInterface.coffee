{ Educators } = require "../collections/educators.coffee"
{ Facilities } = require "../collections/facilities.coffee"
{ ConditionOperations } = require "../collections/condition_operations.coffee"
{ isInt } = require "./utils"
{ getRoleName } = require "./utils"
{ getOperationRoleName } = require "./utils"

class SalesforceInterface

  constructor: ->
    login = Salesforce.login Meteor.settings.SF_USER, Meteor.settings.SF_PASS, Meteor.settings.SF_TOKEN
    console.log "login"
    console.log login

  importFacilities: ->
    facilities = @fetchFacilitiesFromSalesforce()
    for facility in facilities
      if not Facilities.findOne { salesforce_id: facility.Id }
        Facilities.insert {
          name: facility.Name,
          salesforce_id: facility.Id,
          delivery_partner: facility.Delivery_Partner__c
        }

  importConditionOperations: ->
    operations = @fetchConditionOperationsFromSalesforce()
    for operation in operations
      if not ConditionOperations.findOne { salesforce_id: operation.Id }
        facility = operation.Facility__r
        ConditionOperations.insert {
          name: operation.Name,
          salesforce_id: operation.Id,
          facility_salesforce_id: operation.Facility__c
          facility_name: facility.Name
        }
        console.log ConditionOperations.find({}).fetch()

  importEducators: ->
    records = @fetchEducatorsFromSalesforce()
    for record in records
      educator = record.Contact__r
      facility = record.Facility__r
      if not Educators.findOne { uniqueId: educator.Trainee_ID__c }
        console.log "importing educator" + educator.Trainee_ID__c
        phone = if isInt( educator.MobilePhone ) then parseInt(educator.MobilePhone) else null
        Educators.insert {
          last_name: educator.LastName or ""
          first_name: educator.FirstName or ""
          contact_salesforce_id: educator.Id
          department: educator.Department or ""
          salesforce_facility_id: facility.Id
          facility_role_salesforce_id: record.Id
          facility_salesforce_id: facility.Id
          facility_name: facility.Name
          phone: phone or 0
          uniqueId: educator.Trainee_ID__c
        }

  fetchConditionOperationsFromSalesforce: ->
    console.log "Fetching condition operations"
    result = Salesforce.query "SELECT Id, Name, Facility__c, Facility__r.Name FROM Condition_Operation__c"
    return result?.response?.records

  fetchFacilitiesFromSalesforce: ->
    result = Salesforce.query "SELECT Id, Name, Delivery_Partner__c FROM Facility__c"
    return result?.response?.records

  fetchEducatorsFromSalesforce: ->
    # result = Salesforce.query "SELECT Id, FirstName, LastName, MobilePhone, Department, Trainee_Id__c FROM Contact WHERE Trainee_Id__c != ''"
    result = Salesforce.query "SELECT Id, Contact__c, Contact__r.id,
      Contact__r.MobilePhone, Contact__r.FirstName, Contact__r.LastName, Contact__r.Department,
      Contact__r.Trainee_Id__c, Facility__c, Facility__r.Name, Facility__r.id
      FROM Facility_Role__c WHERE Role_With_Noora_Program__c = 'Trainee'"
    return result?.response?.records

  exportConditionOperationRoles: ( educator )->
    return new Promise (resolve, reject)->
      if not educator.condition_operations or educator.condition_operations.length == 0
        resolve([])

      roles = educator.condition_operations.map ( role )->
        name = getOperationRoleName( educator, role )
        return {
          "Name" : name,
          "Is_Active__c": role.is_active,
          "Condition_Operation__c": role.operation_salesforce_id,
          "Contact__c": educator.contact_salesforce_id,
          "Date_Began_Teaching_Classes__c": role.date_started,
          "RecordTypeId": "012j0000000udTH"
        }

      updatedRoles = []
      callback = Meteor.bindEnvironment ( role, err, ret ) ->
        if err
          console.log "Error inserting facility role into Salesforce"
          console.log err
        else
          role.role_salesforce_id = ret.id
        updatedRoles.push role
        if updatedRoles.length == educator.condition_operations.length
          resolve updatedRoles

      #insert into the Salesforce database
      for role, i in roles
        Salesforce.sobject("Condition_Operation_Role__c").create role, callback.bind(this, educator.condition_operations[i])

  # updateConditionOperationRoles: ( educator )->
  #   return new Promise (resolve, reject)->
  #     if educator.condition_operations.length == 0
  #       resolve([])
  #
  #     roles = educator.condition_operations.map ( role )->
  #       return {
  #         "Name" : role.name,
  #         "Id": role.role_salesforce_id,
  #         "Is_Active__c": role.is_active,
  #         "Condition_Operation__c": role.operation_salesforce_id,
  #         "Date_Began_Teaching_Classes__c": role.date_started
  #       }
  #
  #     updatedRoles = []
  #     callback = Meteor.bindEnvironment ( role, err, ret ) ->
  #       if err
  #         console.log "Error updating condition operation in Salesforce"
  #         console.log err
  #         reject(err)
  #       else
  #         updatedRoles.push role
  #         if updatedRoles.length == educator.condition_operations.length
  #           resolve updatedRoles
  #
  #     #insert into the Salesforce database
  #     for role, i in roles
  #       Salesforce.sobject("Condition_Operation_Role__c").update role, "Id", callback.bind(this, educator.condition_operations[i])
  #
  deleteConditionOperationRoles: ( educator )->
    return new Promise ( resolve, reject )->
      result = Salesforce.sobject("Condition_Operation_Role__c").find(
        { 'Contact__c.Id' : educator.salesforce_id },
        {
          Id: 1,
          Name: 1
        }
      ).execute( (err, roles)->
        console.log "in the callback!!"
        deleted = 0
        console.log "about to delete roles"
        console.log roles
        if roles is undefined or roles.length == 0
          console.log "Roles was undefined or length 0"
          resolve()
        for role in roles
          Salesforce.sobject("Condition_Operation_Role__c").destroy role.Id, (err, ret)->
            if err
              console.log "Error deleting condition operations"
              console.log err
              reject err
            else
              console.log "deleted!!"
              deleted++
              if deleted == roles.length
                resolve()

      )

  exportFacilityRole: ( educator )->
    return new Promise (resolve, reject)->
      facilityRole = {
        "Name" : getRoleName(educator)
        "Department__c": educator.department,
        "Facility__c": educator.facility_salesforce_id,
        "Contact__c": educator.contact_salesforce_id,
        "Role_With_Noora_Program__c": Meteor.settings.FACILITY_ROLE_TYPE
      }

      callback = Meteor.bindEnvironment ( err, ret ) ->
        if err
          console.log "Error inserting facility role into Salesforce"
          console.log err
          reject(err)
        else
          console.log "success creating facility role #{educator.contact_salesforce_id}"
          resolve(ret.id)

      #insert into the Salesforce database
      Salesforce.sobject("Facility_Role__c").create facilityRole, callback

  updateFacilityRole: ( educator )->
    return new Promise (resolve, reject)->
      salesforceRole = {
        "Name" : getRoleName(educator)
        "Department__c": educator.department,
        "Id": educator.facility_role_salesforce_id,
        "Facility__c": educator.facility_salesforce_id,
        "Role_With_Noora_Program__c": Meteor.settings.FACILITY_ROLE_TYPE,
      }
      callback = Meteor.bindEnvironment ( err, ret ) ->
        if err
          console.log "Error inserting facility role into Salesforce"
          console.log err
          reject(err)
        else
          console.log "Success updating facility role"
          resolve( educator.facility_role_salesforce_id )

      #insert into the Salesforce database
      Salesforce.sobject("Facility_Role__c").update salesforceRole, "Id", callback

  upsertEducator: ( educator )->
    return new Promise (resolve, reject)->
      facility = Facilities.findOne {
        salesforce_id: educator.facility_salesforce_id
      }
      console.log "Upserting this educator"
      lastName = educator.last_name
      firstName = educator.first_name
      if not lastName or lastName is ""
        lastName = educator.first_name
        firstName = ""

      salesforceContact = {
        "LastName" : lastName or "",
        "FirstName" : firstName or "",
        "MobilePhone" : educator.phone or 0,
        "Department" : educator.department or "",
        "AccountId" : facility.delivery_partner,
        "Trainee_ID__c": educator.uniqueId,
        "RecordTypeId": Meteor.settings.CONTACT_RECORD_TYPE
      }

      callback = Meteor.bindEnvironment ( err, ret ) ->
        if err
          console.log "Error exporting nurse educator"
          console.log err
          reject(err)
        else
          salesforceId = ret.id
          if educator.contact_salesforce_id? and educator.contact_salesforce_id != ""
            salesforceId = educator.contact_salesforce_id
          resolve(salesforceId)

      #insert into the Salesforce database
      Salesforce.sobject("Contact").upsert salesforceContact, "Trainee_ID__c", callback

  exportToSalesforce: ( educator )->
    console.log "about to export to salesforce"
    promise = @upsertEducator(educator)
    that = @
    promise.then((salesforceId )->
      educator.contact_salesforce_id = salesforceId
      Educators.update { uniqueId: educator.uniqueId }, {$set: educator }
      return that.exportFacilityRole educator, false
    ).then(( facilityRoleSalesforceId )->
      educator.facility_role_salesforce_id = facilityRoleSalesforceId
      return that.exportConditionOperationRoles educator
    ).then((condition_operations)->
      educator.condition_operations = condition_operations
      educator.export_error = false
      Educators.update { uniqueId: educator.uniqueId }, {$set: educator }
    ,(err) ->
      console.log "error exporting educators"
      console.log err
      Educators.update { uniqueId: educator.uniqueId }, {$set: { export_error: true }}
    )

  updateInSalesforce: ( educator )->
    console.log "update in salesforce"
    console.log educator
    promise = @upsertEducator(educator)
    that = @
    promise.then((salesforceId )->
      educator.contact_salesforce_id = salesforceId
      console.log "contact updated"
      Educators.update { uniqueId: educator.uniqueId }, {$set: educator }
      return that.updateFacilityRole educator
    ).then(( facilityRoleSalesforceId )->
      educator.facility_role_salesforce_id = facilityRoleSalesforceId
      console.log "facility role updated"
      console.log facilityRoleSalesforceId
      return that.deleteConditionOperationRoles educator.condition_operations
    ).then( ()->
      console.log "deleted the condition operations"
      return that.exportConditionOperationRoles educator
    ).then((condition_operations)->
      educator.condition_operations = condition_operations
      educator.update_error = false
      console.log "this is the educator"
      console.log educator
      Educators.update { uniqueId: educator.uniqueId }, {$set: educator }
    ,(err) ->
      console.log "error upserting educators"
      console.log err
      Educators.update { uniqueId: educator.uniqueId }, {$set: { update_error: true }}
    )

module.exports.SalesforceInterface = SalesforceInterface
