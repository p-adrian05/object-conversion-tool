public with sharing class ObjectUtilController {

    @AuraEnabled(Cacheable = true)
    public static List<FieldResponse> getFieldsBySobjectApiName(String sObjectApiName,Boolean isFormulaIncluded){
        ObjectUtil.requireNonNull(sObjectApiName,'sObjectApiName cannot be null to get fields');
        ObjectUtil.requireNonNull(isFormulaIncluded,'isFormulaIncluded cannot be null to get fields');

        List<SObjectField> sObjectFields =  ObjectUtil.getFieldsForSObject(sObjectApiName,true,true,true,isFormulaIncluded);
        List<FieldResponse> fields = new List<FieldResponse>();
        for(SObjectField sObjectField: sObjectFields){
            DescribeFieldResult fieldResult = sObjectField.getDescribe();
            fields.add(new FieldResponse()
                    .setFieldApiName(fieldResult.getName())
                    .setFieldLabelName(fieldResult.getLabel())
                    .setFieldType(fieldResult.getType().name())
                    .setReferenceTo(fieldResult.getReferenceTo())
                    .setRequired(!fieldResult.isNillable()));
        }
        fields.sort();

        return fields;
    }
    @AuraEnabled(Cacheable=true)
    public static List<SObjectResponse> getSObjects(){
        Map<String,SObjectType> sObjectTypeMap = Schema.getGlobalDescribe();
        List<SObjectResponse> sObjectResponses  = new List<SObjectResponse>();
        for(String key:sObjectTypeMap.keySet()){
            DescribeSObjectResult describeSObjectResult = sObjectTypeMap.get(key).getDescribe();

        if(!describeSObjectResult.isCustomSetting()
                && describeSObjectResult.isCreateable()){

                sObjectResponses.add(new SObjectResponse()
                        .setSObjectApiName(describeSObjectResult.getName())
                        .setSObjectLabelName(describeSObjectResult.getLabel()));
            }
        }
        sObjectResponses.sort();
        return sObjectResponses;
    }
    @AuraEnabled(Cacheable=true)
    public static List<SObjectResponse> getChildObjectApiNamesByParentObjectApiName(String parentSObjectApiName){
        ObjectUtil.requireNonNull(parentSObjectApiName,'parentSObjectApiName cannot be null to get child object api names');

        SObjectType parentObjectType = Schema.getGlobalDescribe().get(parentSObjectApiName);
        List<SObjectResponse> relatedSObjectResponses  = new List<SObjectResponse>();
        for(ChildRelationship childRelationship:parentObjectType.getDescribe().getChildRelationships()){
            DescribeSObjectResult describeSObjectResult =childRelationship.getChildSObject().getDescribe();

            if(describeSObjectResult.isCreateable()
                    && !describeSObjectResult.isCustomSetting()){
                relatedSObjectResponses.add(new SObjectResponse()
                        .setSObjectApiName(childRelationship.getChildSObject().getDescribe().getName())
                        .setSObjectLabelName(childRelationship.getChildSObject().getDescribe().getLabel()));
            }

        }
        relatedSObjectResponses.sort();
        return relatedSObjectResponses;
    }
    @AuraEnabled(Cacheable=true)
    public static List<ObjectRelationship> getObjectRelationships(String parentObjectApiName,String childObjectApiName){
        ObjectUtil.requireNonNull(parentObjectApiName,'parentObjectApiName cannot be null to get object relationships');
        ObjectUtil.requireNonNull(childObjectApiName,'childObjectApiName cannot be null to get object relationships');

        SObjectType sObjectType = ((SObject) Type.forName(parentObjectApiName).newInstance())
                .getSObjectType();
        List<ObjectRelationship> objectRelationships = new List<ObjectRelationship>();

        for(ChildRelationship childRelationship:sObjectType.getDescribe().getChildRelationships()) {
            if(childRelationship.getChildSObject().getDescribe().getName().equals(childObjectApiName)) {
                objectRelationships.add(new ObjectRelationship(childRelationship.getRelationshipName(),
                       childRelationship.getField().getDescribe().name));
            }
        }
        return objectRelationships;
    }
    @AuraEnabled(Cacheable=true)
    public static UserInfoResponse getCurrentUserInfo(){
        Id userId = UserInfo.getUserId();
        Profile profile = [SELECT Name FROM Profile WHERE Id = :UserInfo.getProfileId()];
        return new UserInfoResponse()
                        .setProfileName(profile.Name)
                        .setUserId(userId);
    }

   public class FieldResponse implements Comparable{
        @AuraEnabled public String labelName;
        @AuraEnabled public String apiName;
        @AuraEnabled public String type;
        @AuraEnabled public String referenceTo;
        @AuraEnabled public Boolean required;

        public FieldResponse setFieldLabelName(String fieldLabelName) {
            this.labelName = fieldLabelName;
            return this;
        }

        public FieldResponse setFieldApiName(String fieldApiName) {
            this.apiName = fieldApiName;
            return this;
        }

        public FieldResponse setFieldType(String fieldType) {
            this.type = fieldType;
            return this;
        }

        public FieldResponse setRequired(Boolean required) {
            this.required = required;
            return this;
        }
        public FieldResponse setReferenceTo(List<SObjectType> sObjectTypes) {
            if(sObjectTypes!=null && sObjectTypes.size()!=0){
                this.referenceTo = sObjectTypes.get(0).getDescribe().getName();
            }
            return this;
        }
        public Integer compareTo(Object fieldResponseObject) {
            Integer comparison = 0;
            FieldResponse fieldResponseToCompare = (FieldResponse) fieldResponseObject;
            if (this.labelName > fieldResponseToCompare.labelName) {
                comparison = 1;
            } else if (this.labelName < fieldResponseToCompare.labelName) {
                comparison = -1;
            }
            return comparison;
        }
    }

    public class SObjectResponse implements Comparable{
        @AuraEnabled public String label;
        @AuraEnabled public String objectApiName;

        public SObjectResponse setSObjectLabelName(String sObjectLabelName) {
            this.label = sObjectLabelName;
            return this;
        }

        public SObjectResponse setSObjectApiName(String sObjectApiName) {
            this.objectApiName = sObjectApiName;
            return this;
        }
        public Integer compareTo(Object objectResponse) {
            Integer comparison = 0;
            SObjectResponse objectResponseToCompare = (SObjectResponse) objectResponse;
            if (this.label > objectResponseToCompare.label) {
                comparison = 1;
            } else if (this.label < objectResponseToCompare.label) {
                comparison = -1;
            }
            return comparison;
        }

    }
    public class UserInfoResponse{
        @AuraEnabled public String userId;
        @AuraEnabled public String profileName;
        @AuraEnabled public Boolean isAdmin = false;

        public UserInfoResponse setUserId(Id userId) {
            this.userId = userId;
            return this;
        }

        public UserInfoResponse setProfileName(String profileName) {
            this.profileName = profileName;
            if(profileName.equalsIgnoreCase('System Administrator')){
                this.isAdmin = true;
            }
            return this;
        }
    }
}