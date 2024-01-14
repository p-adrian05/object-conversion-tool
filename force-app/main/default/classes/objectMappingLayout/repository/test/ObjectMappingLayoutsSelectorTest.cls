@IsTest
private class ObjectMappingLayoutsSelectorTest {


    @IsTest
    public static void testGetObjectMappingLayoutShouldReturnSObjectMappedToWrapperObject() {
        //Given
        ObjectMappingLayoutDataFactory.ObjectMappingLayoutResult mappingLayoutResult =
                ObjectMappingLayoutDataFactory.createObjectMappingLayoutWithParentAndChildMapping();

        Object_Mapping_Layout__c mappingLayout = mappingLayoutResult.objectMappingLayout;
        Object_Mapping_Template__c childObjectMappingTemplate = mappingLayoutResult.childObjectMappingTemplates.get(0);
        Object_Mapping__c parentObjectMapping = mappingLayoutResult.parentObjectMapping;
        Object_Mapping__c childObjectMapping = mappingLayoutResult.childObjectMappings.get(0);

        ObjectMappingLayoutsSelector objectMappingLayoutSelector = new ObjectMappingLayoutsSelector();
        //When
        ObjectMappingLayout actualObjectMappingLayoutModel =
                objectMappingLayoutSelector.getObjectMappingLayoutWithObjectMappings(mappingLayout.Id, true);

        //Then
        Assert.isNotNull(actualObjectMappingLayoutModel.parentMapping.template.fieldMappings);
        Assert.areEqual(mappingLayout.Name,actualObjectMappingLayoutModel.name);
        Assert.areEqual(mappingLayout.Id, actualObjectMappingLayoutModel.id);
        Assert.areEqual(mappingLayout.IsDefault__c, actualObjectMappingLayoutModel.isDefault);
        Assert.areEqual(parentObjectMapping.Id, actualObjectMappingLayoutModel.parentMapping.id);

        ObjectMapping actualChildObjectMappingModel = actualObjectMappingLayoutModel.childMappings[0];
        Assert.isNotNull(actualChildObjectMappingModel.template.fieldMappings);

        Assert.areEqual(childObjectMapping.Source_Object_Relationship_JSON__c, JSON.serialize(actualChildObjectMappingModel.sourceObjectRelationship));
        Assert.areEqual(childObjectMapping.Target_Object_Relationship_JSON__c, JSON.serialize(actualChildObjectMappingModel.targetObjectRelationship));
        Assert.isNotNull(actualChildObjectMappingModel.filterState);
        Assert.areEqual(childObjectMapping.External_Id__c, actualChildObjectMappingModel.externalId);

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

        ObjectMappingLayoutsSelector objectMappingLayoutSelector = new ObjectMappingLayoutsSelector();
        //When
        List<ObjectMappingLayout> actualObjectMappingLayouts = objectMappingLayoutSelector.getObjectMappingLayouts();

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

        ObjectMappingLayoutsSelector objectMappingLayoutSelector = new ObjectMappingLayoutsSelector();
        //When
        List<ObjectMappingLayout> actualObjectMappingLayouts = objectMappingLayoutSelector.getObjectMappingLayoutsByParentSourceObject(
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
}