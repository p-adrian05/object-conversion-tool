@IsTest
private class ObjectMappingConverterControllerTest {

    @IsTest
    public static void testConvertObjectShouldReturnConvertedRecordId(){
        //Given
        Object_Mapping_Layout__c objectMappingLayout = ObjectMappingLayoutDataFactory.createObjectMappingLayout('test',true);
        Account sourceAccount = new Account(Name='test');
        insert sourceAccount;
        Contact convertedContact = new Contact(LastName='test');
        insert convertedContact;

        ObjectConversionResult convertedRecordsToReturn = new ObjectConversionResult(convertedContact, new List<SObject>());


        Stub mappingLayoutConverterStub = new Stub(ObjectMappingLayoutConverterServiceImpl.class);
        ObjectMappingConverterController.OBJECT_MAPPING_LAYOUT_CONVERTER_SERVICE = (ObjectMappingLayoutConverterServiceImpl) mappingLayoutConverterStub.instance;
        mappingLayoutConverterStub.setReturnValue('convertObject',convertedRecordsToReturn);

        //When
        Id convertedRecordId = ObjectMappingConverterController.convertObjectFromLayout(sourceAccount.Id,objectMappingLayout.Id);

        //Then
        mappingLayoutConverterStub.assertInvoked('convertObject');
        Assert.isNotNull(convertedRecordId);
    }
}