public with sharing class ObjectMappingTemplateRepositoryImpl implements ObjectMappingTemplateRepository{
    /**
        Returns a single Object_Mapping_Template__c record that matches the specified recordId.

        @param recordId the Id of the record to retrieve.
        @return a single Object_Mapping_Template__c record that matches the specified recordId, or null if no match is found.
    */
    public Object_Mapping_Template__c getObjectMappingTemplateRecord(Id recordId){
        List<Object_Mapping_Template__c> templates =  [SELECT Id, Name, Description__c, Source_Object_Api_Name__c,
                                    Target_Object_Api_Name__c, Mapping_Data__c
                                        FROM Object_Mapping_Template__c WHERE Id=:recordId];
        return templates.size()==1? templates.get(0):null;
    }
    /**
        Returns a list of Object_Mapping_Template__c records that match the specified sourceObjectApiNames
        and targetObjectsApiNames.

        @param sourceObjectApiNames a list of source object API names to match against.
        @param targetObjectsApiNames a list of target object API names to match against.
        @return a list of Object_Mapping_Template__c records that match the specified sourceObjectApiNames and targetObjectsApiNames.
        */
    public List<Object_Mapping_Template__c> getMappingTemplates(List<String> sourceObjectApiNames,
                                                            List<String> targetObjectsApiNames){
        List<Object_Mapping_Template__c> templates = new List<Object_Mapping_Template__c>();
        String queryStr = 'SELECT Id,Name,Source_Object_Api_Name__c,Target_Object_Api_Name__c ' +
                'FROM Object_Mapping_Template__c';

        if(sourceObjectApiNames!=null && sourceObjectApiNames.size()>0){
            queryStr +=' WHERE Source_Object_Api_Name__c IN :sourceObjectApiNames';
            if(targetObjectsApiNames!=null && targetObjectsApiNames.size()>0){
                queryStr+= ' AND Target_Object_Api_Name__c IN :targetObjectsApiNames';
            }
        }else if(targetObjectsApiNames!=null && targetObjectsApiNames.size()>0){
            queryStr+= ' WHERE Target_Object_Api_Name__c IN :targetObjectsApiNames';
        }
        queryStr+=' ORDER BY Name';
        templates = Database.query(queryStr);
        return templates;
    }


}