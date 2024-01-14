public with sharing class ObjectMappingTemplate {
    @AuraEnabled
    public Id id;
    @AuraEnabled
    public String sourceObjectApiName;
    @AuraEnabled
    public String targetObjectApiName;
    @AuraEnabled
    public String name;
    @AuraEnabled
    public String description;
    @AuraEnabled
    public List<FieldMapping> fieldMappings;

    /**
     * Returns a list of API names for source object fields
     * @return List<String> containing field API names
     * @throws IllegalArgumentException if no field mappings are found or if a field mapping does not have a source object field
     */
    public List<String> getSourceObjectFieldApiNames(){
        Set<String> fieldApiNames = new Set<String>();
        if(this.fieldMappings==null||this.fieldMappings.size()==0) {
            throw new IllegalArgumentException('No field mappings found for object mapping template '+this.name);
        }
        for(FieldMapping fieldMapping:this.fieldMappings){
            if(fieldMapping.sourceObjectField==null){
                throw new IllegalArgumentException('No source object field found for field mapping '+fieldMapping);
            }
            fieldApiNames.add(fieldMapping.sourceObjectField.toSOQLFieldName());
        }
        return new List<String>(fieldApiNames);
    }
        /**
        * Creates an ObjectMappingTemplate object from a given Object_Mapping_Template__c SObject.
        * @param objectMappingTemplateSObject the Object_Mapping_Template__c SObject to convert to an ObjectMappingTemplate object
        * @return the converted ObjectMappingTemplate object
    */
    public static ObjectMappingTemplate ofSObject(Object_Mapping_Template__c objectMappingTemplateSObject){
        ObjectMappingTemplate objectMappingTemplate = new ObjectMappingTemplate();
        if(objectMappingTemplateSObject!=null){
            objectMappingTemplate.id = objectMappingTemplateSObject.Id;
            objectMappingTemplate.name = ObjectUtil.getFieldStringValue(objectMappingTemplateSObject,Object_Mapping_Template__c.Name);
            objectMappingTemplate.sourceObjectApiName = ObjectUtil.getFieldStringValue(objectMappingTemplateSObject,Object_Mapping_Template__c.Source_Object_Api_Name__c);
            objectMappingTemplate.targetObjectApiName = ObjectUtil.getFieldStringValue(objectMappingTemplateSObject,Object_Mapping_Template__c.Target_Object_Api_Name__c);
            String fieldMappingsJSON = ObjectUtil.getFieldStringValue(objectMappingTemplateSObject,Object_Mapping_Template__c.Mapping_Data__c);
            if(fieldMappingsJSON!=null && fieldMappingsJSON!=''){
                objectMappingTemplate.fieldMappings = (List<FieldMapping>)JSON.deserialize(fieldMappingsJSON,List<FieldMapping>.class);
            }
            objectMappingTemplate.description = ObjectUtil.getFieldStringValue(objectMappingTemplateSObject,Object_Mapping_Template__c.Description__c);
        }
        return objectMappingTemplate;
    }
    /**
     * Converts a list of Object_Mapping_Template__c SObjects to ObjectMappingTemplate instances.
     *
     * @param objectMappingTemplateSObjects the list of Object_Mapping_Template__c SObjects to convert
     * @return the list of converted ObjectMappingTemplate instances
     */
    public static List<ObjectMappingTemplate> ofSObjects(List<Object_Mapping_Template__c> objectMappingTemplateSObjects){
        List<ObjectMappingTemplate> objectMappingTemplates = new List<ObjectMappingTemplate>();
        if(objectMappingTemplateSObjects==null||objectMappingTemplateSObjects.size()==0){
            return objectMappingTemplates;
        }
        for(Object_Mapping_Template__c objectMappingTemplateSObject : objectMappingTemplateSObjects){
            objectMappingTemplates.add(ObjectMappingTemplate.ofSObject(objectMappingTemplateSObject));
        }
        return objectMappingTemplates;
    }
    /**
     * Converts the ObjectMappingTemplate instance to an Object_Mapping_Template__c SObject.
     *
     * @return the converted Object_Mapping_Template__c SObject instance
     */
    public Object_Mapping_Template__c toSobject(){
        Object_Mapping_Template__c objectMappingTemplateSObject = new Object_Mapping_Template__c();
        objectMappingTemplateSObject.Id = this.id;
        objectMappingTemplateSObject.Name = this.name;
        objectMappingTemplateSObject.Source_Object_Api_Name__c = this.sourceObjectApiName;
        objectMappingTemplateSObject.Target_Object_Api_Name__c = this.targetObjectApiName;
        objectMappingTemplateSObject.Mapping_Data__c = JSON.serialize(this.fieldMappings);
        objectMappingTemplateSObject.Description__c = this.description;
        return objectMappingTemplateSObject;
    }

}