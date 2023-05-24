@IsTest
public with sharing class ObjectMappingTemplateDataFactory {
    public static Object_Mapping_Template__c createObjectMappingTemplate(Boolean doInsert) {
        return createObjectMappingTemplate('Test template','Opportunity','Order',doInsert);
    }
    public static Object_Mapping_Template__c createObjectMappingTemplate(String name, String sourceObjectApiName,
                                                                String targetObjectApiName,Boolean doInsert) {
        Object_Mapping_Template__c template = new Object_Mapping_Template__c(
                Name = name,
                Description__c = 'Test description',
                Source_Object_Api_Name__c = sourceObjectApiName,
                Target_Object_Api_Name__c = targetObjectApiName,
                Mapping_Data__c = '[{"targetObjectField":{"type":"STRING","required":true,"referenceTo":null,"parentField":null,"labelName":"Full Name","apiName":"Name"},' +
                        '"sourceObjectField":{"type":"STRING","required":true,"referenceTo":null,"parentField":null,"labelName":"Account Name","apiName":"Name"},' +
                        '"id":"a00f8c04-32b3-4787-9fea-21427390a3f0"}]'
        );
        if(doInsert){
            insert template;
        }
        return template;
    }
    public static List<Object_Mapping_Template__c> createObjectMappingTemplates(List<String> sourceObjectApiNames,List<String> targetObjectApiNames){
        List<Object_Mapping_Template__c> templates = new List<Object_Mapping_Template__c>();
        for(Integer i = 0; i < sourceObjectApiNames.size(); i++){
            templates.add(createObjectMappingTemplate('Test template ' + i
                    ,sourceObjectApiNames[i],
                    targetObjectApiNames[i],false));
        }
        insert templates;
        return templates;
    }

    public static ObjectMappingTemplate createObjectMappingTemplateModel(String sourceObjectApiName, String targetObjectApiName){
        ObjectMappingTemplate objectMappingTemplate = new ObjectMappingTemplate();
        objectMappingTemplate.name = 'Test Template';
        objectMappingTemplate.description = 'Test Description';
        objectMappingTemplate.sourceObjectApiName = sourceObjectApiName;
        objectMappingTemplate.targetObjectApiName = targetObjectApiName;

        FieldMapping.Field sourceNameField = new FieldMapping.Field('Name','Name',false,'STRING',null);
        FieldMapping.Field targetNameField = new FieldMapping.Field('Name','Name',false,'STRING',null);
        FieldMapping contactPhoneToAccountPhoneMapping = new FieldMapping('3',sourceNameField,targetNameField);

        objectMappingTemplate.fieldMappings = new List<FieldMapping>{contactPhoneToAccountPhoneMapping};

        return objectMappingTemplate;
    }





}