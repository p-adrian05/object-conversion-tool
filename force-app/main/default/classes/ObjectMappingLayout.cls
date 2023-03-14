


public with sharing class ObjectMappingLayout {
    @AuraEnabled
    public Id id;
    @AuraEnabled
    public String name;
    @AuraEnabled
    public String description;
    @AuraEnabled
    public Boolean isDefault;
    @AuraEnabled
    public ObjectMapping parentMapping;
    @AuraEnabled
    public List<ObjectMapping> childMappings;

    public Object_Mapping_Layout__c toSObject(){
        Object_Mapping_Layout__c objectMappingLayout = new Object_Mapping_Layout__c();
        objectMappingLayout.Id = id;
        objectMappingLayout.Name = name;
        objectMappingLayout.Description__c = description;
        objectMappingLayout.IsDefault__c = isDefault == null ? false : isDefault;

        return objectMappingLayout;
    }

    public static ObjectMappingLayout ofSObject(Object_Mapping_Layout__c objectMappingLayoutSObject){
        ObjectMappingLayout objectMappingLayout = new ObjectMappingLayout();
        if(objectMappingLayoutSObject!=null){
            objectMappingLayout.id = objectMappingLayoutSObject.Id;
            objectMappingLayout.name = ObjectUtil.getFieldStringValue(objectMappingLayoutSObject,Object_Mapping_Layout__c.Name);
            objectMappingLayout.description = ObjectUtil.getFieldStringValue(objectMappingLayoutSObject,Object_Mapping_Layout__c.Description__c);
            objectMappingLayout.isDefault = ObjectUtil.getFieldBooleanValue(objectMappingLayoutSObject,Object_Mapping_Layout__c.IsDefault__c);
        }
        return objectMappingLayout;
    }
    public static List<ObjectMappingLayout> ofSObjects(List<Object_Mapping_Layout__c> objectMappingLayoutSObjects){
        List<ObjectMappingLayout> objectMappingLayouts = new List<ObjectMappingLayout>();
        for(Object_Mapping_Layout__c objectMappingLayoutSObject : objectMappingLayoutSObjects){
            objectMappingLayouts.add(ObjectMappingLayout.ofSObject(objectMappingLayoutSObject));
        }
        return objectMappingLayouts;
    }

}