@IsTest
public with sharing class ObjectMappingLayoutServiceTest {
    @IsTest
    static void testInsertNewObjectMappingLayout() {
        //Given
        ObjectMappingLayout objectMappingLayoutModel = ObjectMappingLayoutDataFactory.createObjectMappingLayoutModel();
        ObjectMappingLayoutService objectMappingLayoutService = new ObjectMappingLayoutServiceImpl();

        //When
        Id actualObjectMappingLayoutId = objectMappingLayoutService.upsertObjectMappingLayout(objectMappingLayoutModel);

        //Then
        assertObjectMappingLayout(objectMappingLayoutModel, actualObjectMappingLayoutId);
    }
    @IsTest
    static void testUpdateObjectMappingLayout() {
        //Given
        ObjectMappingLayout objectMappingLayoutModel = ObjectMappingLayoutDataFactory.createObjectMappingLayoutModel();
        objectMappingLayoutModel.id = ObjectMappingLayoutDataFactory.createObjectMappingLayout(objectMappingLayoutModel.name,true).Id;
        objectMappingLayoutModel.parentMapping.id = ObjectMappingLayoutDataFactory.createObjectMapping(objectMappingLayoutModel.id,objectMappingLayoutModel.parentMapping.template.id,true).Id;

        ObjectMapping childObjectMapping = objectMappingLayoutModel.childMappings.get(0);
        childObjectMapping.id = ObjectMappingLayoutDataFactory.createObjectMapping(objectMappingLayoutModel.id,childObjectMapping.template.id,true).Id;

        ObjectMappingLayoutService objectMappingLayoutService = new ObjectMappingLayoutServiceImpl();

        //When
        Id actualObjectMappingLayoutId = objectMappingLayoutService.upsertObjectMappingLayout(objectMappingLayoutModel);

        //Then
        assertObjectMappingLayout(objectMappingLayoutModel, actualObjectMappingLayoutId);
    }
    private static void assertObjectMappingLayout(ObjectMappingLayout actualObjectMappingLayoutModel, Id actualObjectMappingLayoutId) {
        Map<Id, ObjectMapping> objectTemplateIdObjectMappingMap = new Map<Id, ObjectMapping>();

        objectTemplateIdObjectMappingMap.put(actualObjectMappingLayoutModel.parentMapping.template.id, actualObjectMappingLayoutModel.parentMapping);
        for (ObjectMapping objectMapping : actualObjectMappingLayoutModel.childMappings) {
            objectTemplateIdObjectMappingMap.put(objectMapping.template.id, objectMapping);
        }

        Object_Mapping_Layout__c actualObjectMappingLayout = [
                SELECT Id, Name, Description__c, IsDefault__c, (
                        SELECT Id,
                                Object_Mapping_Template__c,
                                Source_Object_Relationship_JSON__c,
                                Filter_State_JSON__c,
                                Target_Object_Relationship_JSON__c
                        FROM Object_Mappings__r
                )
                FROM Object_Mapping_Layout__c
                WHERE Id = :actualObjectMappingLayoutId
        ];

        Assert.areEqual(actualObjectMappingLayoutModel.name, actualObjectMappingLayout.Name);
        Assert.areEqual(actualObjectMappingLayoutModel.isDefault, actualObjectMappingLayout.IsDefault__c);
        Assert.areEqual(actualObjectMappingLayoutModel.description, actualObjectMappingLayout.Description__c);
        Assert.areEqual(actualObjectMappingLayoutModel.childMappings.size() + 1, actualObjectMappingLayout.Object_Mappings__r.size());

        for (Object_Mapping__c actualObjectMapping : actualObjectMappingLayout.Object_Mappings__r) {
            ObjectMapping expectedObjectMapping = objectTemplateIdObjectMappingMap.get(actualObjectMapping.Object_Mapping_Template__c);

            Assert.areEqual(expectedObjectMapping.sourceObjectRelationship, JSON.deserialize(actualObjectMapping.Source_Object_Relationship_JSON__c, ObjectRelationship.class));
            Assert.areEqual(expectedObjectMapping.targetObjectRelationship, JSON.deserialize(actualObjectMapping.Target_Object_Relationship_JSON__c, ObjectRelationship.class));
            Assert.areEqual(expectedObjectMapping.filterState, JSON.deserialize(actualObjectMapping.Filter_State_JSON__c, FilterState.class));
        }
    }

    @IsTest
    static void testRemoveUnlinkedObjectMappingsWhenThereAreUnlinkedObjectMappings() {
        //Given
        Object_Mapping_Template__c oppToOrderTemplate =
                ObjectMappingTemplateDataFactory.createObjectMappingTemplate('Test','Opportunity','Order',true);
        Object_Mapping_Layout__c objectMappingLayout = ObjectMappingLayoutDataFactory.createObjectMappingLayout('Test',true);
        List<Object_Mapping__c> objectMappings = new List<Object_Mapping__c>();
        for (Integer i = 0; i < 5; i++) {
            Object_Mapping__c objectMapping = new Object_Mapping__c();
            objectMapping.Object_Mapping_Layout__c = objectMappingLayout.Id;
            objectMapping.Object_Mapping_Template__c = oppToOrderTemplate.Id;
            objectMappings.add(objectMapping);
        }
        insert objectMappings;
        //Set up the old object mappings
        List<Id> oldObjectMappingIds = new List<Id>();
        for (Object_Mapping__c objectMapping : objectMappings) {
            oldObjectMappingIds.add(objectMapping.Id);
        }
        //set up the new object mappings
        List<Object_Mapping__c> newObjectMappings = new List<Object_Mapping__c>();
        newObjectMappings.add(objectMappings.get(0));
        newObjectMappings.add(objectMappings.get(1));

        ObjectMappingLayoutServiceImpl objectMappingLayoutService = new ObjectMappingLayoutServiceImpl();
        //When
        List<Object_Mapping__c> removedObjectMappings = objectMappingLayoutService.removeUnlinkedObjectMappings(oldObjectMappingIds,newObjectMappings);

        //Then
        Assert.areEqual(3, removedObjectMappings.size());
        for(Object_Mapping__c removedObjectMapping : removedObjectMappings) {
            Assert.isTrue(!newObjectMappings.contains(removedObjectMapping));
        }
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