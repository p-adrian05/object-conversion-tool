public inherited sharing class ObjectMappingTemplatesSelector {

    private List<SObjectField> getSObjectFieldList() {
        return new List<SObjectField>{
                Object_Mapping_Template__c.Name,
                Object_Mapping_Template__c.Description__c,
                Object_Mapping_Template__c.Source_Object_Api_Name__c,
                Object_Mapping_Template__c.Target_Object_Api_Name__c
        };
    }
    private String getFieldListString(List<SObjectField> fields){
        List<String> fieldList = new List<String>();
        for(SObjectField field : fields){
            fieldList.add(field.getDescribe().getName());
        }
        return String.join(fieldList,',');
    }
    /**
          Retrieves the ObjectMappingTemplate records that matches the specified templateIds.

          @param templateIds a Set of template Ids to query for.
          @return the ObjectMappingTemplate object that matches the specified templateId.
      */
    public List<ObjectMappingTemplate> getObjectMappingTemplates(Set<Id> templateIds){
        List<SObjectField> fields = getSObjectFieldList();
        fields.add(Object_Mapping_Template__c.Mapping_Data__c);

        List<Object_Mapping_Template__c> mappingTemplates =
                Database.query('SELECT '+getFieldListString(fields) +
                        ' FROM Object_Mapping_Template__c ' + 'WHERE Id IN :templateIds');

        return ObjectMappingTemplate.ofSObjects(mappingTemplates);
    }
    /**
        Retrieves a list of ObjectMappingTemplate records represented in ObjectMappingTemplate objects that match
        the specified sourceObjectApiNames and targetObjectsApiNames.
        The fieldMappings list excluded from the returned objects.

        @param sourceObjectApiNames a list of source object API names to match against.
        @param targetObjectsApiNames a list of target object API names to match against.
        @return a list of ObjectMappingTemplate objects that match the specified sourceObjectApiNames and targetObjectsApiNames.
*/
    public List<ObjectMappingTemplate> getObjectMappingTemplates(List<String> sourceObjectApiNames,
                                                                     List<String> targetObjectsApiNames){
        List<Object_Mapping_Template__c> mappingTemplates = new List<Object_Mapping_Template__c>();
        String queryStr = 'SELECT '+ getFieldListString(getSObjectFieldList()) +' FROM Object_Mapping_Template__c';

        if(sourceObjectApiNames!=null && sourceObjectApiNames.size()>0){
            queryStr +=' WHERE Source_Object_Api_Name__c IN :sourceObjectApiNames';
            if(targetObjectsApiNames!=null && targetObjectsApiNames.size()>0){
                queryStr+= ' AND Target_Object_Api_Name__c IN :targetObjectsApiNames';
            }
        }else if(targetObjectsApiNames!=null && targetObjectsApiNames.size()>0){
            queryStr+= ' WHERE Target_Object_Api_Name__c IN :targetObjectsApiNames';
        }
        queryStr+=' ORDER BY Name';
        mappingTemplates = Database.query(queryStr);

        return ObjectMappingTemplate.ofSObjects(mappingTemplates);
    }

}