@IsTest
public with sharing class ObjectMappingLayoutUpsertServiceTest {

    @IsTest
    static void testInsertNewObjectMappingLayout() {
        //Given
        ObjectMappingLayout objectMappingLayoutModel = ObjectMappingLayoutDataFactory.createObjectMappingLayoutModel();
        ObjectMappingLayoutUpsertService objectMappingLayoutUpsertService = new ObjectMappingLayoutUpsertServiceImpl();

        //When
        Id actualObjectMappingLayoutId = objectMappingLayoutUpsertService.upsertObjectMappingLayout(objectMappingLayoutModel);

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

        ObjectMappingLayoutUpsertService objectMappingLayoutUpsertService = new ObjectMappingLayoutUpsertServiceImpl();

        //When
        Id actualObjectMappingLayoutId = objectMappingLayoutUpsertService.upsertObjectMappingLayout(objectMappingLayoutModel);

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
                                Filter_Condition__c,
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
            Assert.areEqual(expectedObjectMapping.filterString, actualObjectMapping.Filter_Condition__c);
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

        ObjectMappingLayoutUpsertServiceImpl objectMappingLayoutUpsertService = new ObjectMappingLayoutUpsertServiceImpl();
        //When
        List<Object_Mapping__c> removedObjectMappings =objectMappingLayoutUpsertService.removeUnlinkedObjectMappings(oldObjectMappingIds,newObjectMappings);

        //Then
        Assert.areEqual(3, removedObjectMappings.size());
        for(Object_Mapping__c removedObjectMapping : removedObjectMappings) {
           Assert.isTrue(!newObjectMappings.contains(removedObjectMapping));
        }
    }


}