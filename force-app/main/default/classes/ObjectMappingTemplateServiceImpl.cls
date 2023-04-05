public with sharing class ObjectMappingTemplateServiceImpl implements ObjectMappingTemplateService{

    private final ObjectMappingTemplateRepository objectMappingTemplateRepository;

    public ObjectMappingTemplateServiceImpl(ObjectMappingTemplateRepository objectMappingTemplateRepository){
        this.objectMappingTemplateRepository = objectMappingTemplateRepository;
    }
    /**
        Upserts the specified Object_Mapping_Template__c record represented in ObjectMappingTemplate object.
        @param objectMappingTemplate the ObjectMappingTemplate object to upsert.
        @return the Id of the upserted ObjectMappingTemplate object.
    */
    public Id upsertObjectMappingTemplate(ObjectMappingTemplate objectMappingTemplate) {
        ObjectUtil.requireNonNull(objectMappingTemplate, 'objectMappingTemplate cannot be null to upsert template.');
        ObjectUtil.requireNonEmpty(objectMappingTemplate.fieldMappings, 'Field mappings are required. Please add at least one field mapping on the template: '+objectMappingTemplate.name);

        Object_Mapping_Template__c objectMappingTemplateSObject = objectMappingTemplate.toSobject();

        upsert objectMappingTemplateSObject;

        return objectMappingTemplateSObject.Id;
    }
    /**
        Retrieves the Object_Mapping_Template__c records represented in ObjectMappingTemplate object
        that matches the specified templateId.

        @param templateId the Id of the Object_Mapping_Template__c record to retrieve.
        @return the ObjectMappingTemplate object that matches the specified templateId.
    */
    public ObjectMappingTemplate getObjectMappingTemplate(Id templateId){
        ObjectUtil.requireNonNull(templateId, 'templateId cannot be null to retrieve template.');
        Object_Mapping_Template__c objectMappingTemplateSObject =
                objectMappingTemplateRepository.getObjectMappingTemplateRecord(templateId);

        return ObjectMappingTemplate.ofSObject(objectMappingTemplateSObject);
    }
    /**
        Retrieves a list of Object_Mapping_Template__c records represented in ObjectMappingTemplate objects that match
        the specified sourceObjectApiNames and targetObjectsApiNames.

        @param sourceObjectApiNames a list of source object API names to match against.
        @param targetObjectsApiNames a list of target object API names to match against.
        @return a list of ObjectMappingTemplate objects that match the specified sourceObjectApiNames and targetObjectsApiNames.
*/
    public List<ObjectMappingTemplate> getObjectMappingTemplates(List<String> sourceObjectApiNames,
                                                                 List<String> targetObjectsApiNames){
        List<Object_Mapping_Template__c> mappingTemplates = objectMappingTemplateRepository
                .getMappingTemplates(sourceObjectApiNames, targetObjectsApiNames);
        return ObjectMappingTemplate.ofSObjects(mappingTemplates);
    }
    /**
        Deletes the the Object_Mapping_Template__c record represented in ObjectMappingTemplate object
        that matches the specified templateId.

        @param templateId the Id of the ObjectMappingTemplate object to delete.
        @throws SObjectException if the template has related Object_Mapping_Layout records.
    */
    public void deleteObjectMappingTemplate(Id templateId){
        ObjectUtil.requireNonNull(templateId, 'templateId cannot be null to delete template.');
        List<Object_Mapping__c> objectMappings = [SELECT Id,Object_Mapping_Layout__r.Name
                                                FROM Object_Mapping__c WHERE Object_Mapping_Template__c =:templateId];

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