

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

    public List<String> getSourceObjectFieldApiNames(){
        List<String> fieldApiNames = new List<String>();
        if(this.fieldMappings==null||this.fieldMappings.size()==0) {
            throw new IllegalArgumentException('No field mappings found for object mapping template '+this.name);
        }
        for(FieldMapping fieldMapping:this.fieldMappings){
            if(fieldMapping.sourceObjectField==null){
                throw new IllegalArgumentException('No source object field found for field mapping '+fieldMapping);
            }
            fieldApiNames.add(fieldMapping.sourceObjectField.toSOQLFieldName());
        }
        return fieldApiNames;
    }

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
    public static List<ObjectMappingTemplate> ofSObjects(List<Object_Mapping_Template__c> objectMappingTemplateSObjects){
        List<ObjectMappingTemplate> objectMappingTemplates = new List<ObjectMappingTemplate>();
        for(Object_Mapping_Template__c objectMappingTemplateSObject : objectMappingTemplateSObjects){
            objectMappingTemplates.add(ObjectMappingTemplate.ofSObject(objectMappingTemplateSObject));
        }
        return objectMappingTemplates;
    }
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