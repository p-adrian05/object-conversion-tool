public interface ObjectMappingLayoutUpsertService {
    /**
    * Upserts the specified Object_Mapping_Layout__c record represented in ObjectMappingLayout
    * object with its associated Object_Mapping__c records.

    * @param objectMappingLayout - ObjectMappingLayout object to be upserted
    * @return Id - Id of the upserted ObjectMappingLayout object
    * @throws SObjectException - Throws exception if there is any issue with upserting ObjectMappingLayout record
            or its associated child or parent ObjectMappings
    */
    Id upsertObjectMappingLayout(ObjectMappingLayout objectMappingLayout);
}