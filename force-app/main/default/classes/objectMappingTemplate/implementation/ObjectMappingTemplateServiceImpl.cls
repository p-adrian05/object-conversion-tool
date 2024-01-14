public with sharing class ObjectMappingTemplateServiceImpl implements ObjectMappingTemplateService{
    /**
        Upserts the specified Object_Mapping_Template__c record represented in ObjectMappingTemplate object.
        @param objectMappingTemplate the ObjectMappingTemplate object to upsert.
        @return the Id of the upserted ObjectMappingTemplate object.
    */
    public Id upsertObjectMappingTemplate(ObjectMappingTemplate objectMappingTemplate) {
        ObjectUtil.requireNonNull(objectMappingTemplate, 'objectMappingTemplate cannot be null to upsert template.');
        ObjectUtil.requireNonEmpty(objectMappingTemplate.fieldMappings, 'Field mappings are required. ' +
                'Please add at least one field mapping on the template: '+objectMappingTemplate.name);

        Object_Mapping_Template__c objectMappingTemplateSObject = objectMappingTemplate.toSobject();
        if(!Object_Mapping_Template__c.getSObjectType().getDescribe().isCreateable()){
            throw new SObjectException('Do not have permission to create Object_Mapping_Template__c object.');
        }

        upsert objectMappingTemplateSObject;

        return objectMappingTemplateSObject.Id;
    }
    /**
        Deletes the the Object_Mapping_Template__c record represented in ObjectMappingTemplate object
        that matches the specified templateId.

        @param templateId the Id of the ObjectMappingTemplate object to delete.
        @throws SObjectException if the template has related Object_Mapping_Layout records.
    */
    public void deleteObjectMappingTemplate(Id templateId){
        ObjectUtil.requireNonNull(templateId, 'templateId cannot be null to delete template.');
        if(!Object_Mapping_Template__c.getSObjectType().getDescribe().isDeletable()){
            throw new SObjectException('Do not have permission to delete Object_Mapping_Template__c object.');
        }

        List<Object_Mapping__c> objectMappings = ObjectUtil.executeQueryWithoutSharing('SELECT Id,Object_Mapping_Layout__r.Name '+
                                                            'FROM Object_Mapping__c WHERE Object_Mapping_Template__c =:templateId',
                                                            new Map<String,Object>{'templateId' => templateId});

        if(!objectMappings.isEmpty()){
            List<String> layoutNames = new List<String>();
            for(Object_Mapping__c objectMapping : objectMappings){
                layoutNames.add(objectMapping.Object_Mapping_Layout__r.Name);
            }
            throw new SObjectException('Cannot delete template with related mapping layouts: '+String.join(layoutNames,','));
        }

        Database.DeleteResult deleteResult = Database.delete(templateId);
        if(!deleteResult.isSuccess()){
            throw new SObjectException(String.join(deleteResult.getErrors(),','));
        }
    }

}