public with sharing class ObjectRelationship {
    @AuraEnabled
    public String relationshipName;

    @AuraEnabled
    public String fieldApiName;

    public ObjectRelationship(String relationshipName, String fieldApiName) {
        this.relationshipName = relationshipName;
        this.fieldApiName = fieldApiName;
    }

    public Boolean equals(Object obj) {
        if (obj instanceof ObjectRelationship) {
            ObjectRelationship other = (ObjectRelationship) obj;
            return this.relationshipName == other.relationshipName &&
                    this.fieldApiName == other.fieldApiName;
        }
        return false;
    }

    public Integer hashCode() {
        return (relationshipName != null ? relationshipName.hashCode() : 0) ^
                (fieldApiName != null ? fieldApiName.hashCode() : 0);
    }
}