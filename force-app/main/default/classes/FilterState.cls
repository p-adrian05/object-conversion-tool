

public with sharing class FilterState {
    @AuraEnabled
    public List<ObjectFilter> filterList;
    @AuraEnabled
    public String filterString;
    @AuraEnabled
    public String logicalCondition;
    @AuraEnabled
    public String customLogicalCondition;
}
