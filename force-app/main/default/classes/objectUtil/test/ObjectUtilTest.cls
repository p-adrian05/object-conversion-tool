@IsTest
private class ObjectUtilTest {

    @IsTest
    public static void testRequireNonNullObjectWithObjectShouldReturnObject(){
        Object obj = new List<String>{};
        Object resultObj = ObjectUtil.requireNonNull(obj,'Message');

        System.assert(obj == resultObj);
    }
    @IsTest
    public static void testRequireNonNullObjectWithNullShouldThrowException(){
        Object obj = null;
        Exception expectedException;
        try {
            ObjectUtil.requireNonNull(obj, 'Message');
        }catch (Exception e) {
            expectedException = e;
        }
        System.assert(expectedException != null);
    }
    @IsTest
    public static void testRequireNonNullStringWithStringShouldReturnString(){
        String test = 'test';
        String resultTest = ObjectUtil.requireNonNull(test,'Message');

        System.assert(test.equals(resultTest));
    }
    @IsTest
    public static void testRequireNonNullStringWithNullShouldThrowException(){
        String test = null;
        Exception expectedException;
        try {
            ObjectUtil.requireNonNull(test, 'Message');
        }catch (Exception e) {
            expectedException = e;
        }
        System.assert(expectedException != null);
    }
    @IsTest
    public static void testRequireNonEmptyListWithStringShouldReturnString(){
        List<String> listObj = new List<String>{'test'};
        List<Object> resultListObj = ObjectUtil.requireNonEmpty(listObj,'Message');

        System.assert(listObj == resultListObj);
    }
    @IsTest
    public static void testRequireNonEmptyListWithEmptyListShouldThrowException(){
        List<String> listObj = new List<String>{};
        Exception expectedException;
        try {
            ObjectUtil.requireNonEmpty(listObj, 'Message');
        }catch (Exception e) {
            expectedException = e;
        }
        System.assert(expectedException != null);
    }
    @IsTest
    public static void testRequireNonEmptyListWithNullShouldThrowException(){
        List<String> listObj = null;
        Exception expectedException;
        try {
            ObjectUtil.requireNonEmpty(listObj, 'Message');
        }catch (Exception e) {
            expectedException = e;
        }
        System.assert(expectedException != null);
    }
    @IsTest
    public static void testGetAllFieldsForSObject() {
        List<SObjectField> fields = ObjectUtil.getFieldsForSObject('Account', true, true, true, true);
        Assert.isTrue(fields.size() > 0);
        for (SObjectField field : fields) {
            Assert.isNotNull(field.getDescribe().getName());
            Assert.isNotNull(field.getDescribe().getLabel());
            Assert.isNotNull(field.getDescribe().getType());
        }
    }
    @IsTest
    public static void testGetCustomFieldsForSObject() {
        List<SObjectField> fields = ObjectUtil.getFieldsForSObject('Account', true, false, true, true);
        for (SObjectField field : fields) {
            Assert.isTrue(field.getDescribe().isCustom());
        }
    }
    @IsTest
    public static void testGetStandardFieldsForSObject() {
        List<SObjectField> fields = ObjectUtil.getFieldsForSObject('Account', false, true, true, true);
        for (SObjectField field : fields) {
            Assert.isTrue(!field.getDescribe().isCustom());
        }
    }
    @IsTest
    public static void testGetAllFieldsLargeFieldsExcludedFieldsForSObject() {
        List<SObjectField> fields = ObjectUtil.getFieldsForSObject('Account', true, true, false, true);
        for (SObjectField field : fields) {
            Assert.isTrue(field.getDescribe().getLength() <= 255);
        }
    }
    @IsTest
    public static void testGetAllFieldsCalculatedFieldsExcludedForSObject() {
        List<SObjectField> fields = ObjectUtil.getFieldsForSObject('Account', true, true, true, false);
        for (SObjectField field : fields) {
            Assert.isFalse(field.getDescribe().isCalculated());
        }
    }
    @IsTest
    public static void testGetAllFieldsForSObjectType() {
        List<Schema.SObjectField> fields = ObjectUtil.getAllFieldsForSObjectType('Account');

        Assert.isTrue(fields.size() > 0);

        for (Schema.SObjectField field : fields) {
            Assert.isNotNull(field.getDescribe().getName());
            Assert.isNotNull(field.getDescribe().getLabel());
            Assert.isNotNull(field.getDescribe().getType());
        }
    }
    @IsTest
    public static void testGetFieldStringValue() {
        String accountName = 'Test Account';
        Account acc = new Account(Name = accountName);
        insert acc;

        String nameValue = ObjectUtil.getFieldStringValue(acc, Account.Name);
        Assert.areEqual(accountName, nameValue);

        String nullSObjectValue = ObjectUtil.getFieldStringValue(null, Account.Name);
        Assert.isNull(nullSObjectValue);
    }

    @IsTest
    public static void testGetFieldBooleanValue() {
        Contact con = new Contact(Email = 'test@test.com', LastName = 'Test', DoNotCall = true);
        insert con;

        Boolean emailOptOutValue = ObjectUtil.getFieldBooleanValue(con, Contact.DoNotCall);
        Assert.isTrue(emailOptOutValue);

        Boolean nullSObjectValue = ObjectUtil.getFieldBooleanValue(null, Contact.DoNotCall);
        Assert.isNull(nullSObjectValue);

        Boolean nonBooleanValue = ObjectUtil.getFieldBooleanValue(con, Contact.Id);
        Assert.isNull(nonBooleanValue);

    }

}