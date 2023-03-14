

public interface ObjectMappingTemplateRepository {
    /**
       Returns a single Object_Mapping_Template__c record that matches the specified recordId
       with fields.

       @param recordId the Id of the record to retrieve.
       @return a single Object_Mapping_Template__c record that matches the specified recordId, or null if no match is found.
       */
    Object_Mapping_Template__c getObjectMappingTemplateRecord(Id recordId);
    /**
        Returns a list of Object_Mapping_Template__c records that match the specified sourceObjectApiNames
        and targetObjectsApiNames.

        @param sourceObjectApiNames a list of source object API names to match against.
        @param targetObjectsApiNames a list of target object API names to match against.
        @return a list of Object_Mapping_Template__c records that match the specified sourceObjectApiNames and targetObjectsApiNames.
            */
    List<Object_Mapping_Template__c> getMappingTemplates(List<String> sourceObjectApiNames,
            List<String> targetObjectsApiNames);

}