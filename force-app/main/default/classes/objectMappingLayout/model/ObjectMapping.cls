public with sharing class ObjectMapping {
    @AuraEnabled
    public Id id;
    @AuraEnabled
    public String externalId;
    @AuraEnabled
    public FilterState filterState;
    @AuraEnabled
    public ObjectMappingTemplate template;
    @AuraEnabled
    public ObjectRelationship sourceObjectRelationship;
    @AuraEnabled
    public ObjectRelationship targetObjectRelationship;
    /**
     * Converts an instance of Object_Mapping__c to an SObject with the given layout Id.
     *
     * @param layoutId The Id of the layout for the SObject being created.
     * @return An SObject representation of the Object_Mapping__c instance with the specified layout.
     */
    public Object_Mapping__c toSObject(Id layoutId){
        Object_Mapping__c objectMapping = new Object_Mapping__c();
        objectMapping.Id = id;
        objectMapping.External_Id__c = externalId;
        objectMapping.Object_Mapping_Template__c = template?.id;
        objectMapping.Object_Mapping_Layout__c = layoutId;
        objectMapping.Filter_State_JSON__c = JSON.serialize(filterState);
        objectMapping.Source_Object_Relationship_JSON__c = JSON.serialize(sourceObjectRelationship);
        objectMapping.Target_Object_Relationship_JSON__c = JSON.serialize(targetObjectRelationship);
        return objectMapping;
    }
    /**
    * Converts an Object_Mapping__c SObject to an ObjectMapping domain object.
    * If the SObject is populated with the Object_Mapping_Template__r relationship,then the template model is also converted.
    * @param objectMappingSObject the Object_Mapping__c SObject to convert
    * @return ObjectMapping the converted domain object
    */
    public static ObjectMapping ofSObject(Object_Mapping__c objectMappingSObject){
        ObjectMapping objectMapping = new ObjectMapping();
        if(objectMappingSObject!=null){
            objectMapping.id = objectMappingSObject.Id;
            objectMapping.externalId = ObjectUtil.getFieldStringValue(objectMappingSObject,Object_Mapping__c.External_Id__c);

            String filter_State_JSON = ObjectUtil.getFieldStringValue(objectMappingSObject,Object_Mapping__c.Filter_State_JSON__c);
            if(filter_State_JSON!=null && filter_State_JSON.trim()!=''){
                objectMapping.filterState = (FilterState) JSON.deserialize(filter_State_JSON,FilterState.class);
            }
            String sourceObjectRelationshipJSON = ObjectUtil.getFieldStringValue(objectMappingSObject,Object_Mapping__c.Source_Object_Relationship_JSON__c);
            if(sourceObjectRelationshipJSON!=null && sourceObjectRelationshipJSON!=''){
                objectMapping.sourceObjectRelationship = (ObjectRelationship) JSON.deserialize(sourceObjectRelationshipJSON,ObjectRelationship.class);
            }
            String targetObjectRelationshipJSON = ObjectUtil.getFieldStringValue(objectMappingSObject,Object_Mapping__c.Target_Object_Relationship_JSON__c);
            if(targetObjectRelationshipJSON!=null && targetObjectRelationshipJSON!=''){
                objectMapping.targetObjectRelationship = (ObjectRelationship) JSON.deserialize(targetObjectRelationshipJSON,ObjectRelationship.class);
            }

            try{
                objectMapping.template = ObjectMappingTemplate.ofSObject(objectMappingSObject.Object_Mapping_Template__r);
            }catch (Exception e) {
                objectMapping.template = null;
            }
        }
        return objectMapping;
    }
    /**
       * Convert a List of Object_Mapping__c SObjects to a List of ObjectMapping records.
       * If the SObject is populated with the Object_Mapping_Template__r relationship,then the template model is also converted.
       * @param objectMappingSObjects The List of Object_Mapping__c SObjects to convert
       * @return A List of ObjectMapping records
   */
    public static List<ObjectMapping> ofSObjects(List<Object_Mapping__c> objectMappingSObjects){
        List<ObjectMapping> objectMappings = new List<ObjectMapping>();
        if(objectMappingSObjects!=null){
            for(Object_Mapping__c objectMappingSObject:objectMappingSObjects){
                objectMappings.add(ObjectMapping.ofSObject(objectMappingSObject));
            }
        }
        return objectMappings;
    }

}