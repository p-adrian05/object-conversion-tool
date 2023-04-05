@IsTest
public with sharing class ObjectMappingLayoutServiceTest {

    @IsTest
    public static void testGetObjectMappingLayoutForDisplayShouldReturnSObjectMappedToWrapperObject() {
        //Given
        ObjectMappingLayoutDataFactory.ObjectMappingLayoutResult mappingLayoutResult =
                                ObjectMappingLayoutDataFactory.createObjectMappingLayoutWithParentAndChildMapping();

        Object_Mapping_Layout__c mappingLayout = mappingLayoutResult.objectMappingLayout;
        Object_Mapping_Template__c childObjectMappingTemplate = mappingLayoutResult.childObjectMappingTemplates.get(0);
        Object_Mapping__c parentObjectMapping = mappingLayoutResult.parentObjectMapping;
        Object_Mapping__c childObjectMapping = mappingLayoutResult.childObjectMappings.get(0);

        ObjectMappingLayoutService objectMappingLayoutService = new ObjectMappingLayoutServiceImpl();
        //When
        ObjectMappingLayout actualObjectMappingLayoutModel = objectMappingLayoutService.getObjectMappingLayoutForDisplay(mappingLayout.Id);

        //Then
        Assert.isNull(actualObjectMappingLayoutModel.parentMapping.template.fieldMappings);
        Assert.areEqual(mappingLayout.Name,actualObjectMappingLayoutModel.name);
        Assert.areEqual(mappingLayout.Id, actualObjectMappingLayoutModel.id);
        Assert.areEqual(mappingLayout.IsDefault__c, actualObjectMappingLayoutModel.isDefault);
        Assert.areEqual(parentObjectMapping.Id, actualObjectMappingLayoutModel.parentMapping.id);

        ObjectMapping actualChildObjectMappingModel = actualObjectMappingLayoutModel.childMappings[0];
        Assert.isNull(actualChildObjectMappingModel.template.fieldMappings);

        Assert.areEqual(childObjectMapping.Source_Object_Relationship_JSON__c, JSON.serialize(actualChildObjectMappingModel.sourceObjectRelationship));
        Assert.areEqual(childObjectMapping.Target_Object_Relationship_JSON__c, JSON.serialize(actualChildObjectMappingModel.targetObjectRelationship));
        Assert.isNotNull(actualChildObjectMappingModel.filterState);
        Assert.areEqual(childObjectMapping.External_Id__c, actualChildObjectMappingModel.externalId);

        Assert.areEqual(childObjectMappingTemplate.Id, actualChildObjectMappingModel.template.id);
        Assert.areEqual(childObjectMappingTemplate.Target_Object_Api_Name__c, actualChildObjectMappingModel.template.targetObjectApiName);
        Assert.areEqual(childObjectMappingTemplate.Source_Object_Api_Name__c, actualChildObjectMappingModel.template.sourceObjectApiName);

    }
    @IsTest
    public static void testGetObjectMappingLayoutForConversionShouldReturnSObjectMappedToWrapperObject() {
        //Create templates
        ObjectMappingLayoutDataFactory.ObjectMappingLayoutResult mappingLayoutResult =
                ObjectMappingLayoutDataFactory.createObjectMappingLayoutWithParentAndChildMapping();

        Object_Mapping_Layout__c mappingLayout = mappingLayoutResult.objectMappingLayout;
        Object_Mapping_Template__c childObjectMappingTemplate = mappingLayoutResult.childObjectMappingTemplates.get(0);
        Object_Mapping_Template__c parentObjectMappingTemplate = mappingLayoutResult.parentObjectMappingTemplate;
        Object_Mapping__c parentObjectMapping = mappingLayoutResult.parentObjectMapping;
        Object_Mapping__c childObjectMapping = mappingLayoutResult.childObjectMappings.get(0);

        ObjectMappingLayoutService objectMappingLayoutService = new ObjectMappingLayoutServiceImpl();
        //When
        ObjectMappingLayout actualObjectMappingLayoutModel = objectMappingLayoutService.getObjectMappingLayoutForConversion(mappingLayout.Id);

        // Assert the result
        Assert.isNull(actualObjectMappingLayoutModel.name);
        Assert.isNotNull(actualObjectMappingLayoutModel.parentMapping.template.fieldMappings);

        Assert.areEqual(mappingLayout.Id, actualObjectMappingLayoutModel.id);
        Assert.areEqual(mappingLayout.IsDefault__c, actualObjectMappingLayoutModel.isDefault);
        Assert.areEqual(parentObjectMapping.Id, actualObjectMappingLayoutModel.parentMapping.id);

        Assert.areEqual(parentObjectMappingTemplate.Id, actualObjectMappingLayoutModel.parentMapping.template.id);

        ObjectMapping actualChildObjectMappingModel = actualObjectMappingLayoutModel.childMappings[0];
        Assert.isNotNull(actualChildObjectMappingModel.template.fieldMappings);
        Assert.isNotNull(actualChildObjectMappingModel.filterState);
        Assert.areEqual(childObjectMapping.Source_Object_Relationship_JSON__c, JSON.serialize(actualChildObjectMappingModel.sourceObjectRelationship));
        Assert.areEqual(childObjectMapping.Target_Object_Relationship_JSON__c, JSON.serialize(actualChildObjectMappingModel.targetObjectRelationship));

        Assert.areEqual(childObjectMappingTemplate.Id, actualChildObjectMappingModel.template.id);
        Assert.areEqual(childObjectMappingTemplate.Target_Object_Api_Name__c, actualChildObjectMappingModel.template.targetObjectApiName);
        Assert.areEqual(childObjectMappingTemplate.Source_Object_Api_Name__c, actualChildObjectMappingModel.template.sourceObjectApiName);
    }

    @IsTest
    public static void testGetObjectMappingLayoutsShouldReturnSObjectsMappedToWrapperObject() {
        //Given
        List<Object_Mapping_Layout__c> testObjectMappingLayouts = ObjectMappingLayoutDataFactory.createObjectMappingLayouts(5,true);
        Map<Id,Object_Mapping_Layout__c> testObjectMappingLayoutsMap = new Map<Id,Object_Mapping_Layout__c>();
        for(Object_Mapping_Layout__c layout : testObjectMappingLayouts){
            testObjectMappingLayoutsMap.put(layout.Id,layout);
        }

        ObjectMappingLayoutService objectMappingLayoutService = new ObjectMappingLayoutServiceImpl();
        //When
        List<ObjectMappingLayout> actualObjectMappingLayouts = objectMappingLayoutService.getObjectMappingLayouts();

        //Then
        for(ObjectMappingLayout actualObjectMappingLayout : actualObjectMappingLayouts) {
            Object_Mapping_Layout__c expectedObjectMappingLayout =  testObjectMappingLayoutsMap.get(actualObjectMappingLayout.id);
            Assert.areEqual(expectedObjectMappingLayout.Name,actualObjectMappingLayout.name);
            Assert.areEqual(expectedObjectMappingLayout.IsDefault__c, actualObjectMappingLayout.isDefault);
            Assert.areEqual(expectedObjectMappingLayout.Description__c, actualObjectMappingLayout.description);
        }
    }
    @IsTest
    public static void testGetObjectMappingLayoutsByParentSourceObjectShouldReturnSObjectsMappedToWrapperObject() {
        //Given
        ObjectMappingLayoutDataFactory.createObjectMappingLayouts(5,true);
        ObjectMappingLayoutDataFactory.ObjectMappingLayoutResult createObjectMappingLayoutResult =
                                                                ObjectMappingLayoutDataFactory.createObjectMappingLayoutWithParentAndChildMapping();

        ObjectMappingLayoutService objectMappingLayoutService = new ObjectMappingLayoutServiceImpl();
        //When
        List<ObjectMappingLayout> actualObjectMappingLayouts = objectMappingLayoutService.getObjectMappingLayoutsByParentSourceObject(
                                                                createObjectMappingLayoutResult
                                                                        .parentObjectMappingTemplate
                                                                        .Source_Object_Api_Name__c);

        //Then
        Assert.areEqual(1,actualObjectMappingLayouts.size());
        Object_Mapping_Layout__c expectedObjectMappingLayout = createObjectMappingLayoutResult.objectMappingLayout;
        Assert.areEqual(expectedObjectMappingLayout.Name,actualObjectMappingLayouts.get(0).name);
        Assert.areEqual(expectedObjectMappingLayout.IsDefault__c, actualObjectMappingLayouts.get(0).isDefault);
        Assert.areEqual(expectedObjectMappingLayout.Description__c, actualObjectMappingLayouts.get(0).description);
    }
    @IsTest
    public static void testDeleteObjectMappingLayout() {
        //Given
        Object_Mapping_Layout__c mappingLayoutToDelete = ObjectMappingLayoutDataFactory.createObjectMappingLayoutWithParentAndChildMapping()
                                                            .objectMappingLayout;
        ObjectMappingLayoutService objectMappingLayoutService = new ObjectMappingLayoutServiceImpl();

        //When
        objectMappingLayoutService.deleteObjectMappingLayout(mappingLayoutToDelete.Id);

       //Then
        List<Object_Mapping_Layout__c> deletedLayout = [SELECT Id FROM Object_Mapping_Layout__c WHERE Id = :mappingLayoutToDelete.Id];
        Assert.isTrue(deletedLayout.isEmpty());
    }
    @IsTest
    public static void testMarkDefaultObjectMappingLayout() {
        //Given
        Object_Mapping_Layout__c mappingLayoutToMarkDefault = ObjectMappingLayoutDataFactory.createObjectMappingLayoutWithParentAndChildMapping()
                                                              .objectMappingLayout;
        Object_Mapping_Layout__c mappingLayoutDefault= ObjectMappingLayoutDataFactory.createObjectMappingLayoutWithParentAndChildMapping()
                                                        .objectMappingLayout;
        mappingLayoutDefault.IsDefault__c = true;
        update mappingLayoutDefault;

        ObjectMappingLayoutService objectMappingLayoutService = new ObjectMappingLayoutServiceImpl();

        //When
        objectMappingLayoutService.markDefaultObjectMappingLayout(mappingLayoutToMarkDefault.Id);

        //Then
        List<Object_Mapping_Layout__c> updatedLayouts = [SELECT Id, IsDefault__c FROM Object_Mapping_Layout__c
                                WHERE Id IN :new List<Id>{mappingLayoutToMarkDefault.Id, mappingLayoutDefault.Id}];
        for(Object_Mapping_Layout__c updatedLayout : updatedLayouts) {
            if(updatedLayout.Id == mappingLayoutToMarkDefault.Id) {
                Assert.isTrue(updatedLayout.IsDefault__c);
            } else {
                Assert.isFalse(updatedLayout.IsDefault__c);
            }
        }
    }
    @IsTest
    public static void testMarkDefaultObjectMappingLayoutWithParentMappingNullShouldThrowException() {
        //Given
        Object_Mapping_Layout__c mappingLayoutToMarkDefault = ObjectMappingLayoutDataFactory.createObjectMappingLayoutWithParentAndChildMapping()
                                                                .objectMappingLayout;
        mappingLayoutToMarkDefault.Parent_Object_Mapping__c = null;
        update mappingLayoutToMarkDefault;
        String exceptionMessage;
        ObjectMappingLayoutService objectMappingLayoutService = new ObjectMappingLayoutServiceImpl();
        //When
        try {
            objectMappingLayoutService.markDefaultObjectMappingLayout(mappingLayoutToMarkDefault.Id);
        }catch (SObjectException e) {
            exceptionMessage = e.getMessage();
        }
        //Then
        Assert.isNotNull(exceptionMessage);
    }


}