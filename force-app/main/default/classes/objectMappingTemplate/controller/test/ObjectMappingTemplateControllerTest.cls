@IsTest
public class ObjectMappingTemplateControllerTest {

    @IsTest
    public static void testGetMappingTemplatesByObjectApiNamesShouldReturnListOfRecords() {
        //Given
        List<String> convertFromObjectApiNames = new List<String>{};
        List<String> convertToObjectApiNames = new List<String>{'Opportunity'};

        ObjectMappingTemplate objectMappingTemplateToReturn =
                ObjectMappingTemplateDataFactory.createObjectMappingTemplateModel('Account','Opportunity');

        Stub repositoryStub = new Stub(ObjectMappingTemplatesSelector.class);
        ObjectMappingTemplateController.OBJECT_MAPPING_TEMPLATE_SELECTOR = (ObjectMappingTemplatesSelector) repositoryStub.instance;

        List<ObjectMappingTemplate> mappingTemplatesToReturn = new List<ObjectMappingTemplate>{objectMappingTemplateToReturn};
        repositoryStub.setReturnValue('getObjectMappingTemplates', mappingTemplatesToReturn);

        //When
        List<ObjectMappingTemplate> actualTemplates =
                ObjectMappingTemplateController.getMappingTemplatesByObjectApiNames(convertFromObjectApiNames,convertToObjectApiNames);
        //Then
        repositoryStub.assertInvoked('getObjectMappingTemplates');
        Assert.areEqual(mappingTemplatesToReturn.size(),actualTemplates.size());
        Assert.areEqual(mappingTemplatesToReturn.get(0),objectMappingTemplateToReturn);
    }
    @IsTest
    public static void testGetMappingTemplatesByIdShouldReturnRecord() {
        //Given

        Object_Mapping_Template__c objectMappingTemplate =
                ObjectMappingTemplateDataFactory.createObjectMappingTemplate(true);
        ObjectMappingTemplate objectMappingTemplateToReturn =
                ObjectMappingTemplateDataFactory.createObjectMappingTemplateModel(objectMappingTemplate.Source_Object_Api_Name__c,
                                                    objectMappingTemplate.Target_Object_Api_Name__c);

        Stub repositoryStub = new Stub(ObjectMappingTemplatesSelector.class);
        ObjectMappingTemplateController.OBJECT_MAPPING_TEMPLATE_SELECTOR = (ObjectMappingTemplatesSelector) repositoryStub.instance;

        repositoryStub.setReturnValue('getObjectMappingTemplates',new List<ObjectMappingTemplate>{objectMappingTemplateToReturn});

        //When
         ObjectMappingTemplate actualTemplate =
                ObjectMappingTemplateController.getMappingTemplateById(objectMappingTemplate.Id);
        //Then
        repositoryStub.assertInvoked('getObjectMappingTemplates');
        System.assertEquals(objectMappingTemplateToReturn,actualTemplate);
    }
    @IsTest
    public static void testUpsertMappingTemplateShouldReturnResponseObject() {
        //Given
        String mappingTemplateJSON = '{"sourceObjectApiName":"Account","targetObjectApiName":"Contact",' +
                '"name":"fdsf","fieldMappings":[{"id":"a00f8c04-32b3-4787-9fea-21427390a3f0",' +
                '"sourceObjectField":{"apiName":"Name","labelName":"Account Name","required":true,"type":"STRING"},' +
                '"targetObjectField":{"apiName":"Name","labelName":"Full Name","required":true,"type":"STRING"}}]}';

        Object_Mapping_Template__c objectMappingTemplate =
                ObjectMappingTemplateDataFactory.createObjectMappingTemplate(true);

        Stub repositoryStub = new Stub(ObjectMappingTemplateServiceImpl.class);
        ObjectMappingTemplateController.OBJECT_MAPPING_TEMPLATE_SERVICE = (ObjectMappingTemplateServiceImpl) repositoryStub.instance;
        repositoryStub.setReturnValue('upsertObjectMappingTemplate', objectMappingTemplate.Id);
        //When
        ObjectMappingTemplateController.UpsertTemplateResponse upsertTemplateResponse =
                ObjectMappingTemplateController.upsertMappingTemplate(mappingTemplateJSON);
        //Then
        repositoryStub.assertInvoked('upsertObjectMappingTemplate');
        Assert.isNotNull(upsertTemplateResponse.templateId);
    }
    @IsTest
    public static void testDeleteMappingTemplateShouldReturnDeletedId() {
        //Given
        Object_Mapping_Template__c objectMappingTemplate =
                ObjectMappingTemplateDataFactory.createObjectMappingTemplate(true);

        Stub repositoryStub = new Stub(ObjectMappingTemplateServiceImpl.class);
        ObjectMappingTemplateController.OBJECT_MAPPING_TEMPLATE_SERVICE = (ObjectMappingTemplateServiceImpl) repositoryStub.instance;
        repositoryStub.setReturnValue('deleteObjectMappingTemplate', objectMappingTemplate.Id);
        //When
        String deleteResult =
                ObjectMappingTemplateController.deleteMappingTemplate(objectMappingTemplate.Id);
        //Then
        repositoryStub.assertInvoked('deleteObjectMappingTemplate');
        Assert.isNotNull(deleteResult);
    }
}