public interface ObjectMappingLayoutService {

    /**
    * Upserts the specified Object_Mapping_Layout__c record represented in ObjectMappingLayout
    * object with its associated Object_Mapping__c records.

    * @param objectMappingLayout - ObjectMappingLayout object to be upserted
    * @return Id - Id of the upserted ObjectMappingLayout object
    * @throws SObjectException - Throws exception if there is any issue with upserting ObjectMappingLayout record
            or its associated child or parent ObjectMappings
    */
    Id upsertObjectMappingLayout(ObjectMappingLayout objectMappingLayout);


    /**
     Deletes an Object_Mapping_Layout__c record by the specified ID.

     @param objectMappingLayoutId The ID of the Object Mapping Layout record to delete
     @throws SObjectException if an error occurs during the delete operation
  */
    void deleteObjectMappingLayout(Id objectMappingLayoutId);
    /**

      Marks the specified Object Mapping Layout as default for its parent source object.

      @param objectMappingLayoutId the Id of the Object Mapping Layout to mark as default
      @throws SObjectException if the Object Mapping Layout Id or Parent Source Object API Name is null
      */
    void markDefaultObjectMappingLayout(Id objectMappingLayoutId);
}