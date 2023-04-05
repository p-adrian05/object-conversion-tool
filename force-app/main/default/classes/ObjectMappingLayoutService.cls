public interface ObjectMappingLayoutService {

    /**
        * Retrieves an Object_Mapping_Layout__c represented as ObjectMappingLayout object by its Id with Id, Name fields
        * and with related ObjectMappings (Object_Mapping__c) objects with fields Id,External_Id__c,Filter_State_JSON__c,
        * and with related ObjectMappingTemplate (Object_Mapping_Template__c) objects with fields Id, Source_Object_Api_Name__c
        * and Target_Object_Api_Name__c
        *
        * @param objectMappingLayoutId The Id of the Object_Mapping_Layout__c to retrieve.
        * @return An ObjectMappingLayout object representing the retrieved Object_Mapping_Layout__c record,
        * along with any associated Object_Mapping__c records.
   */
    ObjectMappingLayout getObjectMappingLayoutForDisplay(Id objectMappingLayoutId);
    /**
      * Retrieves an Object_Mapping_Layout__c represented as ObjectMappingLayout object by its Id with Id field
      * with related ObjectMappings (Object_Mapping__c) object with fields Id,Filter_State_JSON__c
      * and with related ObjectMappingTemplate (Object_Mapping_Template__c) object with fields Id, Source_Object_Api_Name__c,
       * Target_Object_Api_Name__c and Mapping_Data__c.
      *
      * @param objectMappingLayoutId The Id of the Object_Mapping_Layout__c to retrieve.
      * @return An ObjectMappingLayout object representing the retrieved Object_Mapping_Layout__c record,
      * along with any associated Object_Mapping__c records.
 */
    ObjectMappingLayout getObjectMappingLayoutForConversion(Id objectMappingLayoutId);
    /**
       * Returns all Object_Mapping_Layout__c represented as ObjectMappingLayout instances with Id, Name and Description fields.
       *
       * @return A list of ObjectMappingLayout instances.
   */
    List<ObjectMappingLayout> getObjectMappingLayouts();
    /**
      * This method returns a list of Object_Mapping_Layout__c represented as ObjectMappingLayout instances
      * with fields Id and Name and Description.
      *
      * @param sourceObjectApiName the API name of the parent source object for which to retrieve associated Object Mapping Layout records
      *
      * @return A list of ObjectMappingLayout instances.
    */
    List<ObjectMappingLayout> getObjectMappingLayoutsByParentSourceObject(String sourceObjectApiName);

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