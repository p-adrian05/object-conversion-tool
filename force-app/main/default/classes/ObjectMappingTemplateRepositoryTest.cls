@IsTest
public class ObjectMappingTemplateRepositoryTest {

    @TestSetup
    public static void testSetup(){
        ObjectMappingTemplateDataFactory.createObjectMappingTemplate('Test template 1',  'Account', 'Contact', true);
        ObjectMappingTemplateDataFactory.createObjectMappingTemplate('Test template 2',  'Account', 'Contact', true);
        ObjectMappingTemplateDataFactory.createObjectMappingTemplate('Test template 3',  'Opportunity', 'Order', true);
        ObjectMappingTemplateDataFactory.createObjectMappingTemplate('Test template 4',  'Contact', 'Lead', true);
    }

    @IsTest
    public static void testGetObjectMappingTemplateRecordShouldReturnTemplate() {
        Object_Mapping_Template__c template = ObjectMappingTemplateDataFactory.createObjectMappingTemplate(true);
        ObjectMappingTemplateRepository objectMappingTemplateRepository = new ObjectMappingTemplateRepositoryImpl();

        Object_Mapping_Template__c returnedTemplate = objectMappingTemplateRepository.getObjectMappingTemplateRecord(template.Id);

        Assert.isNotNull(returnedTemplate);
        Assert.areEqual(template.Id, returnedTemplate.Id);
        Assert.areEqual(template.Name, returnedTemplate.Name);
        Assert.areEqual(template.Description__c, returnedTemplate.Description__c);
        Assert.areEqual(template.Source_Object_Api_Name__c, returnedTemplate.Source_Object_Api_Name__c);
        Assert.areEqual(template.Target_Object_Api_Name__c, returnedTemplate.Target_Object_Api_Name__c);
        Assert.areEqual(template.Mapping_Data__c, returnedTemplate.Mapping_Data__c);
    }
    @IsTest
    public static void testGetObjectMappingTemplateRecordWithInvalidIdShouldReturnNull() {
        ObjectMappingTemplateRepository objectMappingTemplateRepository = new ObjectMappingTemplateRepositoryImpl();

        Object_Mapping_Template__c  returnedTemplate = objectMappingTemplateRepository.getObjectMappingTemplateRecord(null);

        Assert.isNull(returnedTemplate);
    }
    @IsTest
    public static void testGetMappingTemplatesByObjectApiNamesWithConvertFromAndConvertToApiNames() {
        List<String> sourceObjectApiNames = new List<String>{'Account'};
        List<String> targetObjectApiNames = new List<String>{'Contact'};
        ObjectMappingTemplateRepository objectMappingTemplateRepository = new ObjectMappingTemplateRepositoryImpl();

        List<Object_Mapping_Template__c> returnedTemplates =
               objectMappingTemplateRepository.getMappingTemplates(sourceObjectApiNames,targetObjectApiNames);

        Assert.isTrue(returnedTemplates.size()==2);
        for(Object_Mapping_Template__c template:returnedTemplates){
            Assert.isTrue(sourceObjectApiNames.contains(template.Source_Object_Api_Name__c));
            Assert.isTrue(targetObjectApiNames.contains(template.Target_Object_Api_Name__c));
        }

    }
    @IsTest
    public static void testGetMappingTemplatesByObjectApiNamesWithConvertFromApiNames() {
        List<String> sourceObjectApiNames = new List<String>{'Opportunity','Contact'};
        List<String> targetObjectApiNames = null;
        ObjectMappingTemplateRepository objectMappingTemplateRepository = new ObjectMappingTemplateRepositoryImpl();

        List<Object_Mapping_Template__c> returnedTemplates =
                objectMappingTemplateRepository.getMappingTemplates(sourceObjectApiNames,targetObjectApiNames);

        Assert.isTrue(returnedTemplates.size()==2);
        for(Object_Mapping_Template__c template:returnedTemplates){
            Assert.isTrue(sourceObjectApiNames.contains(template.Source_Object_Api_Name__c));
        }

    }
    @IsTest
    public static void testGetMappingTemplatesByObjectApiNamesWithConvertToApiNames() {
        List<String> sourceObjectApiNames = new List<String>{};
        List<String> targetObjectApiNames = new List<String>{'Order','Lead'};
        ObjectMappingTemplateRepository objectMappingTemplateRepository = new ObjectMappingTemplateRepositoryImpl();

        List<Object_Mapping_Template__c> returnedTemplates =
                objectMappingTemplateRepository.getMappingTemplates(sourceObjectApiNames,targetObjectApiNames);

        Assert.isTrue(returnedTemplates.size()==2);
        for(Object_Mapping_Template__c template:returnedTemplates){
            Assert.isTrue(targetObjectApiNames.contains(template.Target_Object_Api_Name__c));
        }
    }
    @IsTest
    public static void testGetMappingTemplatesByObjectApiNamesWithoutApiNamesSpecifiedShouldReturnAllTemplates() {
        ObjectMappingTemplateRepository objectMappingTemplateRepository = new ObjectMappingTemplateRepositoryImpl();

        List<Object_Mapping_Template__c> returnedTemplates =
                objectMappingTemplateRepository.getMappingTemplates(null,null);

        Assert.isTrue(returnedTemplates.size()==4);
    }

}