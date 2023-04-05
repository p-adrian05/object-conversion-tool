public with sharing class ObjectFilter {
    @AuraEnabled
    public String id;
    @AuraEnabled
    public String index;
    @AuraEnabled
    public FieldMapping.Field field;
    @AuraEnabled
    public String operator;
    @AuraEnabled
    public String operatorValue;
    @AuraEnabled
    public String bindVariable;

}