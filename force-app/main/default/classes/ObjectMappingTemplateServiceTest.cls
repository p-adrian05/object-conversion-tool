@IsTest
public class ObjectMappingTemplateServiceTest {


    @IsTest
    static void testUpsertObjectMappingTemplate() {
        // Given
        ObjectMappingTemplate objectMappingTemplate = new ObjectMappingTemplate();
        objectMappingTemplate.name = 'Test Template';
        objectMappingTemplate.sourceObjectApiName = 'Contact';
        objectMappingTemplate.targetObjectApiName = 'Account';
        objectMappingTemplate.description = 'Test Description';

        FieldMapping.Field contactPhoneFromField = new FieldMapping.Field('Phone','Business Phone',false,'PHONE',null);
        FieldMapping.Field accountPhoneToField = new FieldMapping.Field('Phone','Account Phone',false,'PHONE',null);
        FieldMapping contactPhoneToAccountPhoneMapping = new FieldMapping('3',contactPhoneFromField,accountPhoneToField);
        objectMappingTemplate.fieldMappings = new List<FieldMapping>{contactPhoneToAccountPhoneMapping};

        ObjectMappingTemplateService objectMappingTemplateService = new ObjectMappingTemplateServiceImpl();

        // When
        Id actualTemplateId = objectMappingTemplateService.upsertObjectMappingTemplate(objectMappingTemplate);

        // Then
        Assert.isNotNull(actualTemplateId);

        Object_Mapping_Template__c mappingTemplateSObject = [SELECT Id, Name, Source_Object_Api_Name__c, Description__c,
                                                            Target_Object_Api_Name__c, Mapping_Data__c
                                                            FROM Object_Mapping_Template__c WHERE Id = :actualTemplateId LIMIT 1];

        Assert.areEqual(objectMappingTemplate.name, mappingTemplateSObject.Name);
        Assert.areEqual(objectMappingTemplate.sourceObjectApiName, mappingTemplateSObject.Source_Object_Api_Name__c);
        Assert.areEqual(objectMappingTemplate.targetObjectApiName, mappingTemplateSObject.Target_Object_Api_Name__c);
        Assert.areEqual(objectMappingTemplate.description, mappingTemplateSObject.Description__c);
        Assert.areEqual(JSON.serialize(objectMappingTemplate.fieldMappings), mappingTemplateSObject.Mapping_Data__c);

    }


    @IsTest
    static void testDeleteObjectMappingTemplateWithNoRelationToAnyObjectMappingLayout() {
        // Given
        Object_Mapping_Template__c objectMappingTemplateSobject =
                ObjectMappingTemplateDataFactory.createObjectMappingTemplate( true);

        ObjectMappingTemplateService objectMappingTemplateService = new ObjectMappingTemplateServiceImpl();

        // When
        Test.startTest();
        objectMappingTemplateService.deleteObjectMappingTemplate(objectMappingTemplateSobject.Id);
        Test.stopTest();

        // Then
        Assert.areEqual(0,[SELECT Id FROM Object_Mapping_Template__c WHERE Id = :objectMappingTemplateSobject.Id LIMIT 1].size());
    }
    @IsTest
    static void testDeleteObjectMappingTemplateWithRelationToObjectMappingLayout() {
        // Given
        Object_Mapping_Template__c objectMappingTemplateSobject =
                ObjectMappingTemplateDataFactory.createObjectMappingTemplate( true);

        Object_Mapping_Layout__c objectMappingLayoutSobject = new Object_Mapping_Layout__c();
        objectMappingLayoutSobject.Name = 'Test Layout';
        insert objectMappingLayoutSobject;

        Object_Mapping__c objectMappingSobject = new Object_Mapping__c();
        objectMappingSobject.Object_Mapping_Template__c = objectMappingTemplateSobject.Id;
        objectMappingSobject.Object_Mapping_Layout__c = objectMappingLayoutSobject.Id;
        insert objectMappingSobject;

        ObjectMappingTemplateService objectMappingTemplateService = new ObjectMappingTemplateServiceImpl();

        String exceptionMessage;
        // When
        Test.startTest();
        try{
            objectMappingTemplateService.deleteObjectMappingTemplate(objectMappingTemplateSobject.Id);
        }catch (Exception e){
            exceptionMessage = e.getMessage();
        }

        Test.stopTest();

        // Then
        Assert.isNotNull(exceptionMessage);
        Assert.areEqual(objectMappingTemplateSobject.Id,[SELECT Id FROM Object_Mapping_Template__c WHERE Id = :objectMappingTemplateSobject.Id LIMIT 1].Id);
    }

}