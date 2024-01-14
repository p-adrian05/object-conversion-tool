public inherited sharing class ObjectMappingLayoutsSelector {

    /**
     * Retrieves an Object_Mapping_Layout__c represented as ObjectMappingLayout object by its Id.
     *
     * @param objectMappingLayoutId The Id of the Object_Mapping_Layout__c to retrieve.
     * @param isFieldMappingsIncluded If true, the field mappings are included in the template instances.
     * @return An ObjectMappingLayout object representing the retrieved Object_Mapping_Layout__c record,
     * along with any associated Object_Mapping__c records if no Object_Mapping_Layout__c record is found, null is returned.
    */
    public ObjectMappingLayout getObjectMappingLayoutWithObjectMappings(Id objectMappingLayoutId,Boolean isFieldMappingsIncluded){
        ObjectUtil.requireNonNull(objectMappingLayoutId, 'objectMappingLayoutId cannot be null ' +
                'to retrieve ObjectMappingLayout for display.');

        String queryString = 'SELECT Id,Name,IsDefault__c,Parent_Object_Mapping__c,' +
                '(SELECT Id,' +
                'External_Id__c,' +
                'Object_Mapping_Template__c,' +
                'Filter_State_JSON__c,' +
                'Target_Object_Relationship_JSON__c,' +
                'Source_Object_Relationship_JSON__c,' +
                'Object_Mapping_Template__r.Id,' +
                'Object_Mapping_Template__r.Source_Object_Api_Name__c,' +
                'Object_Mapping_Template__r.Target_Object_Api_Name__c,' +
                'Object_Mapping_Template__r.Description__c,' +
                'Object_Mapping_Template__r.Name' +
                (isFieldMappingsIncluded ?',Object_Mapping_Template__r.Mapping_Data__c':' ') +
                ' FROM Object_Mappings__r ) FROM Object_Mapping_Layout__c ' +
                'WHERE Id=:objectMappingLayoutId';

        List<Object_Mapping_Layout__c> objectMappingLayouts = Database.query(queryString);

        Object_Mapping_Layout__c objectMappingLayoutSObject = objectMappingLayouts.size()==1?objectMappingLayouts.get(0):null;
        if(objectMappingLayoutSObject==null){
            return null;
        }
        return ObjectMappingLayout.ofSObject(objectMappingLayoutSObject,objectMappingLayoutSObject.Object_Mappings__r);
    }
    /**
    * Returns all Object_Mapping_Layout__c represented as ObjectMappingLayout instances with Id, Name ,IsDefault and
     * Description fields.
    *
    * @return A list of ObjectMappingLayout instances.
    */
    public List<ObjectMappingLayout> getObjectMappingLayouts(){
        if(!Object_Mapping_Layout__c.getSObjectType().getDescribe().isAccessible()){
            throw new SObjectException('Do not have access to Object_Mapping_Layout__c object.');
        }
        List<Object_Mapping_Layout__c> objectMappingLayoutSObjects =
                Database.query('SELECT Id,Name,Description__c,IsDefault__c'+
                        ' FROM Object_Mapping_Layout__c ORDER BY Name');

        return ObjectMappingLayout.ofSObjects(objectMappingLayoutSObjects);
    }
    /**
      * This method returns a list of Object_Mapping_Layout__c represented as ObjectMappingLayout instances
      * with fields Id ,IsDefault, Name and Description.
      * Sharing rules are NOT enforced for this query.
      * Use this for showing available Object Mapping Layouts for a given source object for any users.
      *
      * @param sourceObjectApiName the API name of the parent source object for which to retrieve associated
       * Object Mapping Layout records
      *
      * @return A list of ObjectMappingLayout instances.
    */
    public List<ObjectMappingLayout> getObjectMappingLayoutsByParentSourceObject(String sourceObjectApiName){
        ObjectUtil.requireNonNull(sourceObjectApiName, 'sourceObjectApiName cannot be null to ' +
                'retrieve ObjectMappingLayouts by parent source object.');

        List<Object_Mapping_Layout__c> objectMappingLayoutSObjects =
                ObjectUtil.executeQueryWithoutSharing('SELECT Id,Name,Description__c, IsDefault__c ' +
                        'FROM Object_Mapping_Layout__c ' +
                        'WHERE Parent_Source_Object_Api_Name__c =:sourceObjectApiName ' +
                        'ORDER BY Name',
                        new Map<String,Object>{'sourceObjectApiName'=>sourceObjectApiName});
        return ObjectMappingLayout.ofSObjects(objectMappingLayoutSObjects);
    }
}