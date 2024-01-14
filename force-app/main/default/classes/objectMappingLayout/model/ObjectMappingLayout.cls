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

    /**
     * Converts an instance of Object_Mapping_Layout__c class to an SObject
     *
     * @return An instance of the Object_Mapping_Layout__c SObject with updated values from the current class instance
     */
    public Object_Mapping_Layout__c toSObject(){
        Object_Mapping_Layout__c objectMappingLayout = new Object_Mapping_Layout__c();
        objectMappingLayout.Id = id;
        objectMappingLayout.Name = name;
        objectMappingLayout.Description__c = description;
        objectMappingLayout.IsDefault__c = isDefault == null ? false : isDefault;

        return objectMappingLayout;
    }
    /**
     * Creates an ObjectMappingLayout instance from an Object_Mapping_Layout__c instance.
     *
     * @param objectMappingLayoutSObject the SObject instance to create the ObjectMappingLayout from.
     * @return the created ObjectMappingLayout instance.
     */
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
    /**
     * Returns an ObjectMappingLayout representation of an Object_Mapping_Layout__c sObject,
     * with its corresponding parent and child Object_Mapping__c sObjects.
     * @param objectMappingLayoutSObject the Object_Mapping_Layout__c sObject to convert
     * @param objectMappings a List of all Object_Mapping__c sObjects associated with the Object_Mapping_Layout__c sObject
     * @return the ObjectMappingLayout object containing the converted sObjects data,
     * or null if the input Object_Mapping_Layout__c sObject is null.
     */
    public static ObjectMappingLayout ofSObject(Object_Mapping_Layout__c objectMappingLayoutSObject, List<Object_Mapping__c> objectMappings){
        if(objectMappingLayoutSObject==null){
            return null;
        }
        List<Object_Mapping__c> childObjectMappingSObjects = new List<Object_Mapping__c>();
        Object_Mapping__c parentObjectMappingSObject;

        //collect child and parent Object_Mapping__c records
        for(Object_Mapping__c objectMappingSObject:objectMappings){
            if(objectMappingSObject.Id == objectMappingLayoutSObject.Parent_Object_Mapping__c){
                parentObjectMappingSObject = objectMappingSObject;
            }else{
                childObjectMappingSObjects.add(objectMappingSObject);
            }
        }
        // create ObjectMappingLayout object
        ObjectMappingLayout objectMappingLayout = ObjectMappingLayout.ofSObject(objectMappingLayoutSObject);

        if(parentObjectMappingSObject!=null){
            //create ObjectMapping objects
            ObjectMapping parentObjectMapping = ObjectMapping.ofSObject(parentObjectMappingSObject);
            List<ObjectMapping> childObjectMappings = ObjectMapping.ofSObjects(childObjectMappingSObjects);
            // set ObjectMapping objects on ObjectMappingLayout object
            objectMappingLayout.parentMapping = parentObjectMapping;
            objectMappingLayout.childMappings = childObjectMappings;
        }
        return objectMappingLayout;
    }
    /**
     * Converts a List of Object_Mapping_Layout__c SObjects to a List of ObjectMappingLayout objects.
     * @param objectMappingLayoutSObjects the List of Object_Mapping_Layout__c SObjects to convert
     * @return a List of ObjectMappingLayout objects that correspond to the input SObjects
     */
    public static List<ObjectMappingLayout> ofSObjects(List<Object_Mapping_Layout__c> objectMappingLayoutSObjects){
        List<ObjectMappingLayout> objectMappingLayouts = new List<ObjectMappingLayout>();
        for(Object_Mapping_Layout__c objectMappingLayoutSObject : objectMappingLayoutSObjects){
            objectMappingLayouts.add(ObjectMappingLayout.ofSObject(objectMappingLayoutSObject));
        }
        return objectMappingLayouts;
    }

}