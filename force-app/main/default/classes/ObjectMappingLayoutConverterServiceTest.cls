@IsTest
private class ObjectMappingLayoutConverterServiceTest {

    @IsTest
    public static void testConvertObjectShouldReturnMapOfTargetRecords() {
        Account sourceAccount = new Account(Name='Test Account',Phone='1234567890');
        insert sourceAccount;
        //setting up the test mapping with data for source and target objects as parent Account => Contact
        ObjectMappingLayout objectMappingLayoutModel = new ObjectMappingLayout();
        ObjectMappingTemplate accountToContactMappingTemplate = ObjectMappingTemplateDataFactory.createObjectMappingTemplateModel('Account','Contact');
        //setting up the fields for the mapping template
        //Name -> LastName
        FieldMapping.Field accountNameField = new FieldMapping.Field('Name','Name',true,'STRING',null);
        FieldMapping.Field contactFirstNameField = new FieldMapping.Field('LastName','Last Name',true,'STRING',null);
        FieldMapping accountContactNameMapping = new FieldMapping('1',accountNameField,contactFirstNameField);
        //BusinessPhone -> AccountPhone
        FieldMapping.Field contactPhoneFromField = new FieldMapping.Field('Phone','Business Phone',false,'PHONE',null);
        FieldMapping.Field accountPhoneToField = new FieldMapping.Field('Phone','Account Phone',false,'PHONE',null);
        FieldMapping accountPhoneToContactPhoneMapping = new FieldMapping('3',contactPhoneFromField,accountPhoneToField);
        accountToContactMappingTemplate.fieldMappings = new List<FieldMapping>{accountContactNameMapping,accountPhoneToContactPhoneMapping};
        //setting up the relationships for the mapping
        ObjectMapping accountToContactMapping = new ObjectMapping();
        accountToContactMapping.template = accountToContactMappingTemplate;
        objectMappingLayoutModel.parentMapping = accountToContactMapping;

        //setting up the stubs
        ObjectMappingLayoutConverterServiceImpl objectMappingLayoutConverterService =
                new ObjectMappingLayoutConverterServiceImpl(new ObjectMappingTemplateConverterImpl());

        //When
        ObjectConversionResult objectConversionResult = objectMappingLayoutConverterService.convertObject(sourceAccount.Id,objectMappingLayoutModel);

        //Then
        Assert.areEqual(0,objectConversionResult.relatedRecords.size());
        Contact actualContact = (Contact) objectConversionResult.parentRecord;
        Assert.areEqual(sourceAccount.Name,actualContact.LastName);
        Assert.areEqual(sourceAccount.Phone,actualContact.Phone);
    }
    @IsTest
    public static void testConvertObjectWithLayoutIdShouldReturnMapOfTargetRecords() {
        Account sourceAccount = new Account(Name='Test Account',Phone='1234567890');
        insert sourceAccount;
        //setting up the test mapping with data for source and target objects as parent Account => Contact
        ObjectMappingLayout objectMappingLayoutModel = new ObjectMappingLayout();
        objectMappingLayoutModel.id = ObjectMappingLayoutDataFactory.createObjectMappingLayout('Account',true).Id;
        ObjectMappingTemplate accountToContactMappingTemplate = ObjectMappingTemplateDataFactory.createObjectMappingTemplateModel('Account','Contact');
        //setting up the fields for the mapping template
        //Name -> LastName
        FieldMapping.Field accountNameField = new FieldMapping.Field('Name','Name',true,'STRING',null);
        FieldMapping.Field contactFirstNameField = new FieldMapping.Field('LastName','Last Name',true,'STRING',null);
        FieldMapping accountContactNameMapping = new FieldMapping('1',accountNameField,contactFirstNameField);
        //BusinessPhone -> AccountPhone
        FieldMapping.Field contactPhoneFromField = new FieldMapping.Field('Phone','Business Phone',false,'PHONE',null);
        FieldMapping.Field accountPhoneToField = new FieldMapping.Field('Phone','Account Phone',false,'PHONE',null);
        FieldMapping accountPhoneToContactPhoneMapping = new FieldMapping('3',contactPhoneFromField,accountPhoneToField);
        accountToContactMappingTemplate.fieldMappings = new List<FieldMapping>{accountContactNameMapping,accountPhoneToContactPhoneMapping};
        //setting up the relationships for the mapping
        ObjectMapping accountToContactMapping = new ObjectMapping();
        accountToContactMapping.template = accountToContactMappingTemplate;
        objectMappingLayoutModel.parentMapping = accountToContactMapping;

        //setting up the stubs
        Stub objectMappingLayoutSelectorStub = new Stub(ObjectMappingLayoutsSelector.class);
        objectMappingLayoutSelectorStub.setReturnValue('getObjectMappingLayoutWithObjectMappings',objectMappingLayoutModel);
        ObjectMappingLayoutConverterServiceImpl objectMappingLayoutConverterService =
                new ObjectMappingLayoutConverterServiceImpl(new ObjectMappingTemplateConverterImpl());

        //When
        ObjectConversionResult objectConversionResult = objectMappingLayoutConverterService.convertObject(sourceAccount.Id,
                            objectMappingLayoutModel.id,(ObjectMappingLayoutsSelector) objectMappingLayoutSelectorStub.instance);

        //Then
        Assert.areEqual(0,objectConversionResult.relatedRecords.size());
        Contact actualContact = (Contact) objectConversionResult.parentRecord;
        Assert.areEqual(sourceAccount.Name,actualContact.LastName);
        Assert.areEqual(sourceAccount.Phone,actualContact.Phone);
    }

    @IsTest
    public static void testConvertChildRecordsShouldReturnListOfTargetRecords() {
        //create parent records
        Account sourceParentAccount = new Account(Name='Test Account');
        insert sourceParentAccount;
        Contact targetParentContact = new Contact(LastName='Test Contact',AccountId=sourceParentAccount.Id,Phone='1234567890');
        insert targetParentContact;
        //setting up the related child records
        Contract sourceChildContract = new Contract(ContractTerm=12,AccountId=sourceParentAccount.Id,Status='Draft');

        insert sourceChildContract;
        //setting up the related child mapping template
        ObjectMappingTemplate attachmentChildMappingTemplate = ObjectMappingTemplateDataFactory.createObjectMappingTemplateModel('Contract','Contract');
        //setting up the fields for the mapping template
        FieldMapping.Field contractTermField = new FieldMapping.Field('ContractTerm','ContractTerm',false,'INTEGER',null);
        FieldMapping.Field contractStatusField = new FieldMapping.Field('Status','Status',false,'PICKLIST',null);
        FieldMapping.Field contractAccountIdField = new FieldMapping.Field('AccountId','AccountId',false,'REFERENCE',null);
        FieldMapping contractTermFieldNameMapping = new FieldMapping('1',contractTermField,contractTermField);
        FieldMapping contractStatusFieldMapping = new FieldMapping('2',contractStatusField,contractStatusField);
        FieldMapping contractAccountIdFieldMapping = new FieldMapping('3',contractAccountIdField,contractAccountIdField);

        attachmentChildMappingTemplate.fieldMappings = new List<FieldMapping>{contractTermFieldNameMapping,contractStatusFieldMapping,contractAccountIdFieldMapping};
        //setting up the relationships for the mapping
        ObjectMapping attachmentChildMapping = new ObjectMapping();
        attachmentChildMapping.template = attachmentChildMappingTemplate;
        attachmentChildMapping.sourceObjectRelationship = new ObjectRelationship('Contracts','AccountId');
        attachmentChildMapping.targetObjectRelationship = new ObjectRelationship('ContractsSigned','CustomerSignedId');

        ObjectMappingLayoutConverterServiceImpl objectMappingLayoutConverterService =
                new ObjectMappingLayoutConverterServiceImpl(new ObjectMappingTemplateConverterImpl());

        //Whem
        List<SObject> targetChildRecords = objectMappingLayoutConverterService.convertRelatedRecords(sourceParentAccount.Id,targetParentContact.Id,
                                                                        new List<ObjectMapping>{attachmentChildMapping});

        //Then
        System.debug('targetChildRecords: '+targetChildRecords);
        Assert.areEqual(1,targetChildRecords.size());
        Contract actualTargetChildRecord = (Contract) targetChildRecords.get(0);
        Assert.areEqual(sourceChildContract.ContractTerm,actualTargetChildRecord.ContractTerm);
        Assert.areEqual(sourceChildContract.Status,actualTargetChildRecord.Status);
        Assert.areEqual(targetParentContact.Id,actualTargetChildRecord.CustomerSignedId);
        Assert.areEqual(sourceChildContract.AccountId,actualTargetChildRecord.AccountId);
    }


    @IsTest
    private static void testGetRelatedSourceRecordsShouldReturnMapOfSourceRecords() {
        //Given
        //setting up the test mapping with data only for source objects as parent Account => null with related Contact => null,
        // we are only testing querying the source records
        //Create test records
        Account account = new Account(Name='Test Account');
        insert account;
        Contact contact = new Contact(LastName='Test Contact',AccountId=account.Id,Phone='1234567890');
        contact.AccountId = account.Id;
        insert contact;

        //setting up the related child mapping template
        ObjectMappingTemplate contactChildMappingTemplate = ObjectMappingTemplateDataFactory.createObjectMappingTemplateModel('Contact','Case');
        //setting up the fields for the mapping template
        FieldMapping.Field accountNameField = new FieldMapping.Field('Name','Account Name',true,'STRING',null);
        FieldMapping.Field contactAccountIdRefFromField = new FieldMapping.Field('AccountId','Account ID',false,'REFERENCE',accountNameField);
        FieldMapping contactRefAccountNameMapping = new FieldMapping('1',contactAccountIdRefFromField,null);

        FieldMapping.Field contactPhoneFromField = new FieldMapping.Field('Phone','Business Phone',false,'PHONE',null);
        FieldMapping contactPhoneToAccountPhoneMapping = new FieldMapping('3',contactPhoneFromField,null);

        contactChildMappingTemplate.fieldMappings = new List<FieldMapping>{contactRefAccountNameMapping,contactPhoneToAccountPhoneMapping};
        //setting up the relationships for the mapping
        ObjectMapping contactChildMapping = new ObjectMapping();
        contactChildMapping.template = contactChildMappingTemplate;
        contactChildMapping.sourceObjectRelationship = new ObjectRelationship('Contacts','AccountId');
        contactChildMapping.targetObjectRelationship = new ObjectRelationship('Test','TestId');

        //setting up the stubs
        Stub objectTemplateConverterStub = new Stub(ObjectMappingTemplateConverter.class);

        //Mocking the ObjectMappingTemplateConverter
        ObjectMappingLayoutConverterServiceImpl objectMappingLayoutConverterService =
                new ObjectMappingLayoutConverterServiceImpl((ObjectMappingTemplateConverter) objectTemplateConverterStub.instance);
        //When
        List<ObjectMappingLayoutConverterServiceImpl.RelatedObject> relatedSourceObjects = objectMappingLayoutConverterService
                                                                        .getRelatedSourceRecords(account.Id,new List<ObjectMapping>{contactChildMapping});
        //Then
        System.debug('relatedSourceObjects: '+relatedSourceObjects);
        Assert.areEqual(1,relatedSourceObjects.size());
        //Assert the source relationship name
        Assert.areEqual(contactChildMapping,relatedSourceObjects.get(0).objectMapping);
        //Assert the source record
        List<SObject> sourceRecords = relatedSourceObjects.get(0).records;
        Contact actualContactSourceRecord = (Contact) sourceRecords.get(0);

        Assert.areEqual(contact.Id,actualContactSourceRecord.Id);
        Assert.isNotNull(actualContactSourceRecord.Phone);
        Assert.areEqual(contact.Phone,actualContactSourceRecord.Phone);
        Assert.areEqual(account.Name,actualContactSourceRecord.Account.Name);
    }
}