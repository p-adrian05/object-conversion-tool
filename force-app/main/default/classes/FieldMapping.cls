public with sharing class FieldMapping{

    @AuraEnabled
    public String id;
    @AuraEnabled
    public Field sourceObjectField;
    @AuraEnabled
    public Field targetObjectField;

    public FieldMapping(String id, Field sourceObjectField, Field targetObjectField) {
        this.id = id;
        this.sourceObjectField = sourceObjectField;
        this.targetObjectField = targetObjectField;
    }

    public class Field{
        @AuraEnabled
        public String apiName;
        @AuraEnabled
        public String labelName;
        @AuraEnabled
        public String referenceTo;
        @AuraEnabled
        public Boolean required;
        @AuraEnabled
        public String type;
        @AuraEnabled
        public Field parentField;

        public Field(String apiName, String labelName, Boolean required, String type, Field parentField) {
            this.apiName = apiName;
            this.labelName = labelName;
            this.required = required;
            this.type = type;
            this.parentField = parentField;
        }
        /**
        * Returns the API name of the field in SOQL format.
         * If the field is a lookup field, the API name of the field will be returned in the format of "ParentObject__r.ParentField__c".
         * @return the API name of the field in SOQL format.
       */
        public String toSOQLFieldName(){
            if(parentField!=null){
                String parentApiName = apiName;
                if(parentApiName == null || parentApiName == ''){
                    throw new IllegalArgumentException('Field api name cannot be null or empty on '+this);
                }
                if(parentApiName.endsWith('__c')){
                    parentApiName = parentApiName.substring(0,parentApiName.lastIndexOfIgnoreCase('c'));
                    parentApiName += 'r';
                }
                else if(parentApiName.endsWith('Id')){
                    parentApiName = parentApiName.substring(0,parentApiName.lastIndexOfIgnoreCase('Id'));
                }
                return parentApiName +'.'+parentField.toSOQLFieldName();
            }
            return apiName;
        }
    }

}