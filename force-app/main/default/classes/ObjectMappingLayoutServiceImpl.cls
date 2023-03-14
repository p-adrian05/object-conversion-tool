
public with sharing class ObjectMappingLayoutServiceImpl implements ObjectMappingLayoutService{

    /**
     * Retrieves an Object_Mapping_Layout__c represented as ObjectMappingLayout object by its Id with Id, IsDefault and  Name fields
     * and with related ObjectMappings (Object_Mapping__c) objects with fields Id,External_Id__c,Filter_State_JSON__c,
     *      Target_Object_Relationship_JSON__c,Source_Object_Relationship_JSON__c,
     * and with related ObjectMappingTemplate (Object_Mapping_Template__c) objects with fields Id, Source_Object_Api_Name__c
     * and Target_Object_Api_Name__c
     *
     * @param objectMappingLayoutId The Id of the Object_Mapping_Layout__c to retrieve.
     * @return An ObjectMappingLayout object representing the retrieved Object_Mapping_Layout__c record,
     * along with any associated Object_Mapping__c records if no Object_Mapping_Layout__c record is found, null is returned.
    */
    public ObjectMappingLayout getObjectMappingLayoutForDisplay(Id objectMappingLayoutId){
        ObjectUtil.requireNonNull(objectMappingLayoutId, 'objectMappingLayoutId cannot be null to retrieve ObjectMappingLayout for display.');
        List<Object_Mapping_Layout__c> objectMappingLayouts = [SELECT Id,Name,IsDefault__c,Parent_Object_Mapping__c,
                                                    (SELECT Id,
                                                            External_Id__c,
                                                            Filter_State_JSON__c,
                                                            Target_Object_Relationship_JSON__c,
                                                            Source_Object_Relationship_JSON__c,
                                                            Object_Mapping_Template__c,
                                                            Object_Mapping_Template__r.Source_Object_Api_Name__c,
                                                            Object_Mapping_Template__r.Target_Object_Api_Name__c
                                                    FROM Object_Mappings__r ) FROM Object_Mapping_Layout__c
                                                    WHERE Id=:objectMappingLayoutId];

         return createObjectMappingLayoutWithObjectMappings(objectMappingLayouts.size()==1?objectMappingLayouts.get(0):null);
    }
    /**
    * Retrieves an Object_Mapping_Layout__c represented as ObjectMappingLayout object by its Id with Id field and IsDefault fields
    * with related ObjectMappings (Object_Mapping__c) object with fields Id,Filter_Condition__c,
     *      Target_Object_Relationship_JSON__c,Source_Object_Relationship_JSON__c,
    * and with related ObjectMappingTemplate (Object_Mapping_Template__c) object with fields Id, Source_Object_Api_Name__c,
     * Target_Object_Api_Name__c and Mapping_Data__c.
    *
    * @param objectMappingLayoutId The Id of the Object_Mapping_Layout__c to retrieve.
    * @return An ObjectMappingLayout object representing the retrieved Object_Mapping_Layout__c record,
    * along with any associated Object_Mapping__c records if no Object_Mapping_Layout__c record is found, null is returned.
   */
    public ObjectMappingLayout getObjectMappingLayoutForConversion(Id objectMappingLayoutId){
        ObjectUtil.requireNonNull(objectMappingLayoutId, 'objectMappingLayoutId cannot be null to retrieve ObjectMappingLayout for conversion.');
        List<Object_Mapping_Layout__c> objectMappingLayouts = [SELECT Id, IsDefault__c, Parent_Object_Mapping__c,
                                                            (SELECT Id,
                                                                    Filter_Condition__c,
                                                                    Object_Mapping_Template__c,
                                                                    Target_Object_Relationship_JSON__c,
                                                                    Source_Object_Relationship_JSON__c,
                                                                    Object_Mapping_Template__r.Source_Object_Api_Name__c,
                                                                    Object_Mapping_Template__r.Target_Object_Api_Name__c,
                                                                    Object_Mapping_Template__r.Mapping_Data__c
                                                            FROM Object_Mappings__r) FROM Object_Mapping_Layout__c
                                                            WHERE Id=:objectMappingLayoutId];

        return createObjectMappingLayoutWithObjectMappings(objectMappingLayouts.size()==1?objectMappingLayouts.get(0):null);
    }
    /**
        Creates an ObjectMappingLayout object using the given Object_Mapping_Layout__c SObject.

        @param objectMappingLayoutSObject the Object_Mapping_Layout__c SObject to create the ObjectMappingLayout object from
        @return the ObjectMappingLayout object created from the Object_Mapping_Layout__c SObject or null if the given SObject is null
   */
    private ObjectMappingLayout createObjectMappingLayoutWithObjectMappings(Object_Mapping_Layout__c objectMappingLayoutSObject){
        if(objectMappingLayoutSObject==null){
            return null;
        }
        List<Object_Mapping__c> childObjectMappingSObjects = new List<Object_Mapping__c>();
        Object_Mapping__c parentObjectMappingSObject;

        // collect child and parent Object_Mapping__c records
        for(Object_Mapping__c objectMappingSObject:objectMappingLayoutSObject.Object_Mappings__r){
            if(objectMappingSObject.Id == objectMappingLayoutSObject.Parent_Object_Mapping__c){
                parentObjectMappingSObject = objectMappingSObject;
            }else{
                childObjectMappingSObjects.add(objectMappingSObject);
            }
        }
        // create ObjectMappingLayout object
        ObjectMappingLayout objectMappingLayout = ObjectMappingLayout.ofSObject(objectMappingLayoutSObject);

        if(parentObjectMappingSObject!=null){
            //create ObjectMapping objects
            ObjectMapping parentObjectMapping = ObjectMapping.ofSObject(parentObjectMappingSObject);
            List<ObjectMapping> childObjectMappings = ObjectMapping.ofSObjects(childObjectMappingSObjects);
            // set ObjectMapping objects on ObjectMappingLayout object
            objectMappingLayout.parentMapping = parentObjectMapping;
            objectMappingLayout.childMappings = childObjectMappings;
        }
        return objectMappingLayout;
    }
    /**
    * Returns all Object_Mapping_Layout__c represented as ObjectMappingLayout instances with Id, Name ,IsDefault and
     * Description fields.
    *
    * @return A list of ObjectMappingLayout instances.
    */
    public List<ObjectMappingLayout> getObjectMappingLayouts(){
        List<Object_Mapping_Layout__c> objectMappingLayoutSObjects =[SELECT Id,Name,Description__c,IsDefault__c
                                                                    FROM Object_Mapping_Layout__c ORDER BY Name];

        return ObjectMappingLayout.ofSObjects(objectMappingLayoutSObjects);
    }
    /**
      * This method returns a list of Object_Mapping_Layout__c represented as ObjectMappingLayout instances
      * with fields Id ,IsDefault, Name and Description.
      *
      * @param sourceObjectApiName the API name of the parent source object for which to retrieve associated Object Mapping Layout records
      *
      * @return A list of ObjectMappingLayout instances.
    */
    public List<ObjectMappingLayout> getObjectMappingLayoutsByParentSourceObject(String sourceObjectApiName){
        ObjectUtil.requireNonNull(sourceObjectApiName, 'sourceObjectApiName cannot be null to retrieve ObjectMappingLayouts by parent source object.');
        List<Object_Mapping_Layout__c> objectMappingLayoutSObjects =
                                                    [SELECT Id,Name,Description__c, IsDefault__c
                                                        FROM Object_Mapping_Layout__c
                                                        WHERE Parent_Source_Object_Api_Name__c =:sourceObjectApiName
                                                        ORDER BY Name];

        return ObjectMappingLayout.ofSObjects(objectMappingLayoutSObjects);
    }
    /**
    Deletes an Object_Mapping_Layout__c record by the specified ID. If the layout record has a parent Object_Mapping__c,
    the parent field is first cleared to avoid deleting a parent record while a child is still referencing it.

    @param objectMappingLayoutId The ID of the Object Mapping Layout record to delete
    @throws SObjectException if an error occurs during the delete operation
    */
    public void deleteObjectMappingLayout(Id objectMappingLayoutId){
        ObjectUtil.requireNonNull(objectMappingLayoutId, 'objectMappingLayoutId cannot be null to delete ObjectMappingLayout.');

        List<Object_Mapping_Layout__c> layouts = [SELECT Id, Parent_Object_Mapping__c FROM
                                                Object_Mapping_Layout__c WHERE Id = :objectMappingLayoutId];
        if(layouts.size()>0) {
            Savepoint savepoint = Database.setSavepoint();
            Object_Mapping_Layout__c layout = layouts.get(0);

            try{
                if(layout.Parent_Object_Mapping__c!=null){
                    layout.Parent_Object_Mapping__c = null;
                    update layout;
                }
                delete layout;
            }catch (Exception e){
                Database.rollback(savepoint);
                System.debug(e.getMessage());
                throw new SObjectException(e.getMessage());
            }
        }
    }
    /**

    Marks the specified Object Mapping Layout as default for its parent source object.

    @param objectMappingLayoutId the Id of the Object Mapping Layout to mark as default
    @throws SObjectException if the Object Mapping Layout Id or Parent Source Object API Name is null
    */
    public void markDefaultObjectMappingLayout(Id objectMappingLayoutId){
        ObjectUtil.requireNonNull(objectMappingLayoutId, 'objectMappingLayoutId cannot be null to mark ObjectMappingLayout as default.');

        String parentSourceObjectApiName = [SELECT Parent_Source_Object_Api_Name__c FROM Object_Mapping_Layout__c
                                        WHERE Id =:objectMappingLayoutId]?.Parent_Source_Object_Api_Name__c;

        if(parentSourceObjectApiName == null){
            throw new SObjectException('Parent Source Object API Name is null to mark it default ' +
                    'Id' + objectMappingLayoutId);
        }
        // clear all other default layouts for the parent source object
        List<Object_Mapping_Layout__c> layouts = [SELECT Id, IsDefault__c FROM Object_Mapping_Layout__c
                                            WHERE Parent_Source_Object_Api_Name__c =:parentSourceObjectApiName];
        if(layouts.size()>0) {
            for(Object_Mapping_Layout__c layout : layouts){
                if(layout.Id == objectMappingLayoutId) {
                    layout.IsDefault__c = true;
                } else {
                    layout.IsDefault__c = false;
                }
            }
        }
        update layouts;
    }

}