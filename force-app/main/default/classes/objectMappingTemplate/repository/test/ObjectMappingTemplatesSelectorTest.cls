@IsTest
public with sharing class ObjectMappingTemplatesSelectorTest {
    @TestSetup
    public static void testSetup(){
        ObjectMappingTemplateDataFactory.createObjectMappingTemplate('Test template 1',  'Account', 'Contact', true);
        ObjectMappingTemplateDataFactory.createObjectMappingTemplate('Test template 2',  'Account', 'Contact', true);
        ObjectMappingTemplateDataFactory.createObjectMappingTemplate('Test template 3',  'Opportunity', 'Order', true);
        ObjectMappingTemplateDataFactory.createObjectMappingTemplate('Test template 4',  'Contact', 'Lead', true);
    }
    @IsTest
    static void testGetObjectMappingTemplate() {
        // Given
        String templateName = 'Test name';
        String sourceObjectApiName = 'Account';
        String targetObjectApiName = 'Contact';
        Object_Mapping_Template__c objectMappingTemplateSobject =
                ObjectMappingTemplateDataFactory.createObjectMappingTemplate(templateName, sourceObjectApiName, targetObjectApiName, true);

        ObjectMappingTemplatesSelector objectMappingTemplateService = new ObjectMappingTemplatesSelector();

        // When
        List<ObjectMappingTemplate> actualObjectMappingTemplates =
                objectMappingTemplateService.getObjectMappingTemplates(new Set<Id>{objectMappingTemplateSobject.Id});

        // Then
        Assert.areEqual(1,actualObjectMappingTemplates.size());
        ObjectMappingTemplate actualObjectMappingTemplate = actualObjectMappingTemplates[0];
        Assert.areEqual(templateName, actualObjectMappingTemplate.name);
        Assert.areEqual(sourceObjectApiName, actualObjectMappingTemplate.sourceObjectApiName);
        Assert.areEqual(targetObjectApiName, actualObjectMappingTemplate.targetObjectApiName);
        Assert.areEqual(objectMappingTemplateSobject.Mapping_Data__c, JSON.serialize(actualObjectMappingTemplate.fieldMappings));
    }
    @IsTest
    public static void testGetMappingTemplatesByObjectApiNamesWithConvertFromAndConvertToApiNames() {
        List<String> sourceObjectApiNames = new List<String>{'Account'};
        List<String> targetObjectApiNames = new List<String>{'Contact'};
        ObjectMappingTemplatesSelector objectMappingTemplateService = new ObjectMappingTemplatesSelector();

        List<ObjectMappingTemplate> returnedTemplates =
                objectMappingTemplateService.getObjectMappingTemplates(sourceObjectApiNames,targetObjectApiNames);

        Assert.isTrue(returnedTemplates.size()==2);
        for(ObjectMappingTemplate template:returnedTemplates){
            Assert.isTrue(sourceObjectApiNames.contains(template.sourceObjectApiName));
            Assert.isTrue(targetObjectApiNames.contains(template.targetObjectApiName));
        }

    }
    @IsTest
    public static void testGetMappingTemplatesByObjectApiNamesWithConvertFromApiNames() {
        List<String> sourceObjectApiNames = new List<String>{'Opportunity','Contact'};
        List<String> targetObjectApiNames = null;
        ObjectMappingTemplatesSelector objectMappingTemplateService = new ObjectMappingTemplatesSelector();

        List<ObjectMappingTemplate> returnedTemplates =
                objectMappingTemplateService.getObjectMappingTemplates(sourceObjectApiNames,targetObjectApiNames);

        Assert.isTrue(returnedTemplates.size()==2);
        for(ObjectMappingTemplate template:returnedTemplates){
            Assert.isTrue(sourceObjectApiNames.contains(template.sourceObjectApiName));
        }

    }
    @IsTest
    public static void testGetMappingTemplatesByObjectApiNamesWithConvertToApiNames() {
        List<String> sourceObjectApiNames = new List<String>{};
        List<String> targetObjectApiNames = new List<String>{'Order','Lead'};
        ObjectMappingTemplatesSelector objectMappingTemplateService = new ObjectMappingTemplatesSelector();

        List<ObjectMappingTemplate> returnedTemplates =
                objectMappingTemplateService.getObjectMappingTemplates(sourceObjectApiNames,targetObjectApiNames);

        Assert.isTrue(returnedTemplates.size()==2);
        for(ObjectMappingTemplate template:returnedTemplates){
            Assert.isTrue(targetObjectApiNames.contains(template.targetObjectApiName));
        }
    }
    @IsTest
    public static void testGetMappingTemplatesByObjectApiNamesWithoutApiNamesSpecifiedShouldReturnAllTemplates() {
        ObjectMappingTemplatesSelector objectMappingTemplateService = new ObjectMappingTemplatesSelector();

        List<ObjectMappingTemplate> returnedTemplates =
                objectMappingTemplateService.getObjectMappingTemplates(null,null);

        Assert.isTrue(returnedTemplates.size()==4);
    }
}