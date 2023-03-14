

public interface ObjectMappingTemplateService {
    /**
        Upserts the specified Object_Mapping_Template__c record represented in ObjectMappingTemplate object.
        @param objectMappingTemplate the ObjectMappingTemplate object to upsert.
        @return the Id of the upserted ObjectMappingTemplate object.
        */
    Id upsertObjectMappingTemplate(ObjectMappingTemplate objectMappingTemplate);
    /**
        Retrieves the Object_Mapping_Template__c records represented in ObjectMappingTemplate object that
        matches the specified templateId.

        @param templateId the Id of the Object_Mapping_Template__c record to retrieve.
        @return the ObjectMappingTemplate object that matches the specified templateId.
        */
    ObjectMappingTemplate getObjectMappingTemplate(Id templateId);
    /**
        Retrieves a list of Object_Mapping_Template__c records represented in ObjectMappingTemplate objects that match
        the specified sourceObjectApiNames and targetObjectsApiNames.

        @param sourceObjectApiNames a list of source object API names to match against.
        @param targetObjectsApiNames a list of target object API names to match against.
        @return a list of ObjectMappingTemplate objects that match the specified sourceObjectApiNames and targetObjectsApiNames.
*/
    List<ObjectMappingTemplate> getObjectMappingTemplates(List<String> sourceObjectApiNames,
                                                            List<String> targetObjectsApiNames);
    /**
      Deletes the the Object_Mapping_Template__c record represented in ObjectMappingTemplate object
      that matches the specified templateId.

      @param templateId the Id of the ObjectMappingTemplate object to delete.
      @throws SObjectException if the template has related Object_Mapping_Layout records.
  */
    void deleteObjectMappingTemplate(Id templateId);
}