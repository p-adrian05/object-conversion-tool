@IsTest
public with sharing class ObjectMappingTemplateConverterTest {

    @IsTest
    public static void testConvertRecords() {
        //Given
        Account accountParentForReports = new Account();
        accountParentForReports.Name = 'Test Account Name ';
        accountParentForReports.BillingCity = 'Amsterdam';
        insert accountParentForReports;

        Account accountParentForContact = new Account();
        accountParentForContact.Name = 'Test Account Name from Contact';

        insert accountParentForContact;

        Contact reportsToContact = new Contact();
        reportsToContact.LastName = 'test last Name Reports To';
        reportsToContact.AccountId = accountParentForReports.Id;


        insert reportsToContact;

        Contact contactSourceRecord = new Contact();
        contactSourceRecord.LastName = 'LastName';
        contactSourceRecord.Phone = '132123';
        contactSourceRecord.AccountId = accountParentForContact.Id;
        contactSourceRecord.ReportsToId = reportsToContact.Id;

        insert contactSourceRecord;


        //Contact        ->     Account
        //AccountId
        //   - AccountName -> AccountName
        FieldMapping.Field accountNameField = new FieldMapping.Field('Name','Account Name',true,'STRING',null);
        FieldMapping.Field contactAccountIdRefFromField = new FieldMapping.Field('AccountId','Account ID',false,'REFERENCE',accountNameField);
        FieldMapping.Field accountNameToField = new FieldMapping.Field('Name','Account Name',true,'STRING',null);
        FieldMapping contactRefAccountNameToAccountNameMapping = new FieldMapping('1',contactAccountIdRefFromField,accountNameToField);

        //ReportsToId
        //   - AccountId
        //      - BillingCity -> BillingCity
        FieldMapping.Field accountBillingCityField = new FieldMapping.Field('BillingCity','Billing City',false,'STRING',null);
        FieldMapping.Field accountIdRefField = new FieldMapping.Field('AccountId','Account ID',false,'REFERENCE',accountBillingCityField);
        FieldMapping.Field contactReportsToIdRefAccountBillingCityFromField = new FieldMapping.Field('ReportsToId','Reports To ID',false,'REFERENCE',accountIdRefField);
        FieldMapping.Field accountBillingCityToField = new FieldMapping.Field('BillingCity','Billing City',false,'STRING',null);
        FieldMapping contactRefReportsRefAccountBillingCityToBillingCityMapping = new FieldMapping('2',contactReportsToIdRefAccountBillingCityFromField,accountBillingCityToField);

        //BusinessPhone -> AccountPhone
        FieldMapping.Field contactPhoneFromField = new FieldMapping.Field('Phone','Business Phone',false,'PHONE',null);
        FieldMapping.Field accountPhoneToField = new FieldMapping.Field('Phone','Account Phone',false,'PHONE',null);
        FieldMapping contactPhoneToAccountPhoneMapping = new FieldMapping('3',contactPhoneFromField,accountPhoneToField);

        List<FieldMapping> fieldMappings = new List<FieldMapping>{contactRefAccountNameToAccountNameMapping,
                contactRefReportsRefAccountBillingCityToBillingCityMapping,
                contactPhoneToAccountPhoneMapping};

        ObjectMappingTemplate objectMappingTemplate = new ObjectMappingTemplate();
        objectMappingTemplate.fieldMappings = fieldMappings;
        objectMappingTemplate.sourceObjectApiName = 'Contact';
        objectMappingTemplate.targetObjectApiName = 'Account';

        ObjectMappingTemplateConverter objectConverterService = new ObjectMappingTemplateConverterImpl();

        //When
        Map<Id, SObject> actualConvertedAccountMap = objectConverterService.convertRecords(new List<Id>{contactSourceRecord.Id},objectMappingTemplate);

        //Then
        Assert.areEqual(1,actualConvertedAccountMap.size());
        Account account = (Account) actualConvertedAccountMap.get(contactSourceRecord.Id);

        Assert.areEqual(accountParentForReports.BillingCity,account.BillingCity);
        Assert.areEqual(contactSourceRecord.Phone,account.Phone);
        Assert.areEqual(accountParentForContact.Name,account.Name);

    }

    @IsTest
    static void testConvertRecordsWithInvalidSourceRecordTypeShouldThrowException() {
        //Given
        List<Id> sourceRecordIds = new List<Id>();
        Account account = new Account();
        account.Name = 'Test Account Name ';
        account.BillingCity = 'Amsterdam';
        insert account;
        sourceRecordIds.add(account.Id);

        ObjectMappingTemplateConverter objectConverterService = new ObjectMappingTemplateConverterImpl();
        ObjectMappingTemplate objectMappingTemplateModel =
                ObjectMappingTemplateDataFactory.createObjectMappingTemplateModel('Opportunity','Contact');

        String exceptionMessage;
        //When
        try {
            Map<Id, SObject> result = objectConverterService.convertRecords(sourceRecordIds,objectMappingTemplateModel);
            Assert.fail();
        } catch (Exception e) {
            exceptionMessage = e.getMessage();

        }
        //Then
        Assert.isNotNull(exceptionMessage, 'Exception message should not be null');
        Assert.isTrue(exceptionMessage.containsIgnoreCase('Invalid record to convert'));

    }



}