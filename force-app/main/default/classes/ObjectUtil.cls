public with sharing class ObjectUtil {

    /**
    *   Checks that the specified object reference is not null.
    *   This method is designed primarily for doing parameter validation in methods and constructors.
    *
    *   @param obj - the object reference to check for nullity
    *   @param message - detail message to be used in the event that a IllegalArgumentException is thrown
    *
    *   @return: obj if not null
    *   @throws:IllegalArgumentException - if obj is null
   */
    public static Object requireNonNull(Object obj, String message){
        if (obj == null){
            throw new IllegalArgumentException(message);
        }
        return obj;
    }
    /**
     *   Checks that the specified String is not null.
     *   This method is designed primarily for doing parameter validation in methods and constructors.
     *
     *   @param str - a string value to check for nullity
     *   @param message - detail message to be used in the event that a IllegalArgumentException is thrown
     *
     *   @return: str if not null
     *   @throws:IllegalArgumentException - if str is null
    */
    public static String requireNonNull(String str, String message){
        if (str == null){
            throw new IllegalArgumentException(message);
        }
        return str;
    }
    /**
   *   Checks that the specified List of objects is not null and not empty
   *   This method is designed primarily for doing parameter validation in methods and constructors.
   *
   *   @param objs - a List of Objects to check for nullity
   *   @param message - detail message to be used in the event that a IllegalArgumentException is thrown
   *
   *   @return: objs if or not null and contains more than 0 element
   *   @throws:IllegalArgumentException - if objs is null or empty
  */
    public static List<Object> requireNonEmpty(List<Object> objs, String message){
        if(objs == null){
            requireNonNull(objs,message);
        }else if (objs.size()==0){
            throw new IllegalArgumentException(message);
        }
        return objs;
    }

    /**
    The getFieldStringValue method is used to retrieve the String value of a specific field from a given SObject.
    @param sObjectSource The SObject from which the value should be retrieved.
    @param fieldToGetValue The SObjectField that represents the field from which the value should be retrieved.
    @return The String value of the field, or null if an exception is thrown while trying to retrieve the value.
    */
    public static String getFieldStringValue(SObject sObjectSource, SObjectField fieldToGetValue){
        Object value = getFieldValue(sObjectSource, fieldToGetValue);
        if(value != null){
            return (String) value;
        }
        return null;
    }
    /**
     The getFieldStringValue method is used to retrieve the Boolean value of a specific field from a given SObject.
     @param sObjectSource The SObject from which the value should be retrieved.
     @param fieldToGetValue The SObjectField that represents the field from which the value should be retrieved.
     @return The Boolean value of the field, or null if an exception is thrown while trying to retrieve the value.
 */
    public static Boolean getFieldBooleanValue(SObject sObjectSource, SObjectField fieldToGetValue){
        Object value = getFieldValue(sObjectSource, fieldToGetValue);
        if(value != null && value instanceof Boolean){
            return (Boolean) value;
        }
        return null;
    }
    /**
      The getFieldValue method is used to retrieve the value of a specific field from a given SObject.
      @param sObjectSource The SObject from which the value should be retrieved.
      @param fieldToGetValue The SObjectField that represents the field from which the value should be retrieved.
      @return The value of the field, or null if the field is not set on the SObject.
  */
    public static Object getFieldValue(SObject sObjectSource, SObjectField fieldToGetValue){
        Object value;

        if(sObjectSource!=null && sObjectSource.isSet(fieldToGetValue)){
            value = sObjectSource.get(fieldToGetValue.getDescribe().getName());
        }
        return value;
    }
    /**
        The getFieldsForSObject method is used to retrieve a list of fields from a specific SObject, based on various criteria.
        @param objectType The name of the SObject for which the fields should be retrieved.
        @param isCustom A Boolean value that indicates whether custom fields should be included in the returned list.
        @param isStandard A Boolean value that indicates whether standard fields should be included in the returned list.
        @param includeLargeText A Boolean value that indicates whether fields with a length greater than 255 characters should be included in the returned list.
        @param isCalculated A Boolean value that indicates whether calculated fields should be included in the returned list.
        @return A list of SObjectField objects that represent the fields that match the criteria.
        */
    public static List<SObjectField> getFieldsForSObject(String objectType,Boolean isCustom,Boolean isStandard,
            Boolean includeLargeText,Boolean isCalculated){

        List<Schema.SObjectField> fieldsToReturn = new List<Schema.SObjectField>();
        List<Schema.SObjectField> sObjectFields = getAllFieldsForSObjectType(objectType);

        for(Schema.SObjectField field: sObjectFields){
            if((isCustom && field.getDescribe().isCustom()) || (isStandard && !field.getDescribe().isCustom())){
                if((!includeLargeText && field.getDescribe().getLength() > 255) ||
                        (!isCalculated && field.getDescribe().isCalculated())){
                    continue;
                }
                fieldsToReturn.add(field);
            }
        }
        return fieldsToReturn;
    }
    /**
        The getAllFieldsForSObjectType method is used to retrieve a list of all fields for a specific SObject.
        @param sObjectTypeName The name of the SObject for which the fields should be retrieved.
        @return A list of SObjectField objects that represent the fields for the SObject.
    */
    public static List<Schema.SObjectField> getAllFieldsForSObjectType(String sObjectTypeName) {
        SObjectType type = Schema.getGlobalDescribe().get(sObjectTypeName);
        Map<String, Schema.SObjectField> sObjectFields = type.getDescribe().fields.getMap();

        return sObjectFields.values();
    }
    /**
     * Executes a SOQL query without enforcing sharing rules.
     *
     * @param query      the SOQL query to be executed
     * @param bindMap    a map of named parameter bindings for the query
     * @return a list of SObject records resulting from the query
     */
    public static List<SObject> executeQueryWithoutSharing(String query,Map<String,Object> bindMap){
        return new WithoutSharingContext().executeQuery(query,bindMap);
    }
    without sharing class WithoutSharingContext{
        public List<SObject> executeQuery(String query,Map<String,Object> bindMap){
            return Database.queryWithBinds(query,bindMap,AccessLevel.SYSTEM_MODE);
        }
    }
}