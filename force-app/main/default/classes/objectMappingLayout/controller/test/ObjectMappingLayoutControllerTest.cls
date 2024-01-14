@IsTest
private class ObjectMappingLayoutControllerTest {
    @IsTest
    public static void testGetMappingLayoutsShouldReturnListOfRecords() {
        //Given
        List<ObjectMappingLayout> objectMappingLayoutsToReturn = new List<ObjectMappingLayout>{
                ObjectMappingLayoutDataFactory.createObjectMappingLayoutModel()};

        Stub layoutSelectorStub = new Stub(ObjectMappingLayoutsSelector.class);
        ObjectMappingLayoutController.OBJECT_MAPPING_LAYOUT_SELECTOR = (ObjectMappingLayoutsSelector) layoutSelectorStub.instance;

        layoutSelectorStub.setReturnValue('getObjectMappingLayouts', objectMappingLayoutsToReturn);

        //When
        List<ObjectMappingLayout> actualLayouts = ObjectMappingLayoutController.getMappingLayouts();
        //Then
        layoutSelectorStub.assertInvoked('getObjectMappingLayouts');
        Assert.areEqual(objectMappingLayoutsToReturn.size(),actualLayouts.size());
        Assert.areEqual(objectMappingLayoutsToReturn.get(0),actualLayouts.get(0));
    }
    @IsTest
    public static void testGetMappingLayoutByIdShouldReturnLayoutRecord() {
        //Given
        ObjectMappingLayout objectMappingLayoutToReturn = ObjectMappingLayoutDataFactory.createObjectMappingLayoutModel();
        objectMappingLayoutToReturn.id = ObjectMappingLayoutDataFactory.createObjectMappingLayout(objectMappingLayoutToReturn.name,true).Id;

        Stub layoutSelectorStub = new Stub(ObjectMappingLayoutsSelector.class);
        ObjectMappingLayoutController.OBJECT_MAPPING_LAYOUT_SELECTOR = (ObjectMappingLayoutsSelector) layoutSelectorStub.instance;

        layoutSelectorStub.setReturnValue('getObjectMappingLayoutWithObjectMappings', objectMappingLayoutToReturn);

        //When
        ObjectMappingLayout actualLayout = ObjectMappingLayoutController.getMappingLayout(objectMappingLayoutToReturn.id);
        //Then
        layoutSelectorStub.assertInvoked('getObjectMappingLayoutWithObjectMappings');
        Assert.areEqual(objectMappingLayoutToReturn,actualLayout);
    }
    @IsTest
    public static void testUpsertMappingLayoutShouldReturnResponseObject() {
        //Given
        Object_Mapping_Layout__c objectMappingLayout = ObjectMappingLayoutDataFactory.createObjectMappingLayout('test',true);

        Stub layoutServiceStub = new Stub(ObjectMappingLayoutServiceImpl.class);
        ObjectMappingLayoutController.OBJECT_MAPPING_LAYOUT_SERVICE = (ObjectMappingLayoutServiceImpl) layoutServiceStub.instance;

        layoutServiceStub.setReturnValue('upsertObjectMappingLayout', objectMappingLayout.Id);
        String layoutJSON = '{"id":"a016800000TBHtCAAX","name":"oppToOrderLayout","description":"desc",' +
                '"parentMapping":{"id":"a0268000003Ge5nAAC","filterState":null,' +
                '"template":{"id":"a0068000006PzTVAA0","sourceObjectApiName":"Opportunity","targetObjectApiName":"Order"},' +
                '"externalId":"35d7a368-ecb2-4a11-b54c-4a72434a1fa5"},' +
                '"childMappings":[{"id":"a0268000003H7GxAAK","filterState":{"filterList":[{"id":1678433707892,"index":1,' +
                 '"field":{"apiName":"Discount","labelName":"Discount","required":false,"type":"PERCENT"},"operator":"<","operatorValue":"33"}],' +
                    '"filterString":" Discount <  33 ","logicalCondition":"AND","customLogicalCondition":"1"},' +
                    '"template":{"id":"a0068000006PzaPAAS","sourceObjectApiName":"OpportunityLineItem","targetObjectApiName":"OrderItem"},' +
                    '"externalId":"b9f9a8c7-e662-4195-8e1b-f02cf4970cc4","sourceObjectRelationship":' +
                    '{"relationshipName":"OpportunityLineItems","fieldApiName":"OpportunityId"},' +
                    '"targetObjectRelationship":{"relationshipName":"OrderItems","fieldApiName":"OrderId"}}]}';
        //When
        ObjectMappingLayoutController.UpsertLayoutResponse actualUpsertLayoutResponse =
                                        ObjectMappingLayoutController.upsertMappingLayout(layoutJSON);
        //Then
        layoutServiceStub.assertInvoked('upsertObjectMappingLayout');
        Assert.areEqual(actualUpsertLayoutResponse.layoutId,objectMappingLayout.Id);
    }
    @IsTest
    public static void testDeleteMappingLayoutLayoutShouldReturnSuccessMessage(){
        //Given
        Object_Mapping_Layout__c objectMappingLayout = ObjectMappingLayoutDataFactory.createObjectMappingLayout('test',true);

        Stub layoutServiceStub = new Stub(ObjectMappingLayoutServiceImpl.class);
        ObjectMappingLayoutController.OBJECT_MAPPING_LAYOUT_SERVICE = (ObjectMappingLayoutServiceImpl) layoutServiceStub.instance;
        layoutServiceStub.setReturnValue('deleteObjectMappingLayout', objectMappingLayout.Id);
        //When
        String deleteResult = ObjectMappingLayoutController.deleteMappingLayout(objectMappingLayout.Id);

        //Then
        layoutServiceStub.assertInvoked('deleteObjectMappingLayout');
        Assert.isNotNull(deleteResult);
    }
    @IsTest
    public static void testGetMappingLayoutBySourceRecordIdShouldReturnLayoutRecords(){
        //Given
        List<ObjectMappingLayout> objectMappingLayoutsToReturn = new List<ObjectMappingLayout>{
                ObjectMappingLayoutDataFactory.createObjectMappingLayoutModel()};
        Account sourceAccount = new Account(Name = 'test');
        insert sourceAccount;

        Stub layoutSelectorStub = new Stub(ObjectMappingLayoutsSelector.class);
        ObjectMappingLayoutController.OBJECT_MAPPING_LAYOUT_SELECTOR = (ObjectMappingLayoutsSelector) layoutSelectorStub.instance;


        layoutSelectorStub.setReturnValue('getObjectMappingLayoutsByParentSourceObject', objectMappingLayoutsToReturn);

        //When
        List<ObjectMappingLayout> actualLayouts = ObjectMappingLayoutController.getObjectMappingLayoutsBySourceRecordId(sourceAccount.Id);
        //Then
        layoutSelectorStub.assertInvoked('getObjectMappingLayoutsByParentSourceObject');
        Assert.areEqual(objectMappingLayoutsToReturn.size(),actualLayouts.size());
        Assert.areEqual(objectMappingLayoutsToReturn.get(0),actualLayouts.get(0));
    }
    @IsTest
    public static void testMarkDefaultLayoutShouldReturnSuccessMessage(){
        //Given
        ObjectMappingLayout objectMappingLayout = ObjectMappingLayoutDataFactory.createObjectMappingLayoutModel();
        objectMappingLayout.id = ObjectMappingLayoutDataFactory.createObjectMappingLayout(objectMappingLayout.name,true).Id;

        Stub layoutServiceStub = new Stub(ObjectMappingLayoutServiceImpl.class);
        ObjectMappingLayoutController.OBJECT_MAPPING_LAYOUT_SERVICE = (ObjectMappingLayoutServiceImpl) layoutServiceStub.instance;
        layoutServiceStub.setReturnValue('markDefaultObjectMappingLayout', objectMappingLayout.id);
        //When
        String operationResult = ObjectMappingLayoutController.markDefaultLayout(objectMappingLayout.id);

        //Then
        layoutServiceStub.assertInvoked('markDefaultObjectMappingLayout');
        Assert.isNotNull(operationResult);
    }
}