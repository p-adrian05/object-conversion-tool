public interface ObjectMappingTemplateService {
    /**
        Upserts the specified Object_Mapping_Template__c record represented in ObjectMappingTemplate object.
        @param objectMappingTemplate the ObjectMappingTemplate object to upsert.
        @return the Id of the upserted ObjectMappingTemplate object.
        */
    Id upsertObjectMappingTemplate(ObjectMappingTemplate objectMappingTemplate);
    /**
      Deletes the the Object_Mapping_Template__c record represented in ObjectMappingTemplate object
      that matches the specified templateId.

      @param templateId the Id of the ObjectMappingTemplate object to delete.
      @throws SObjectException if the template has related Object_Mapping_Layout records.
  */
    void deleteObjectMappingTemplate(Id templateId);
}