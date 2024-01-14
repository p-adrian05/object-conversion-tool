public with sharing class ObjectMappingTemplateController {
    @TestVisible
    private static ObjectMappingTemplateService OBJECT_MAPPING_TEMPLATE_SERVICE = new ObjectMappingTemplateServiceImpl();
    @TestVisible
    private static ObjectMappingTemplatesSelector OBJECT_MAPPING_TEMPLATE_SELECTOR = new ObjectMappingTemplatesSelector();

    /**
      * Returns a list of all ObjectMappingTemplate records that map the given source and target objectApiNames.
      *
      * @param sourceObjectApiNames A list of API names of source objects to search for.
      * @param targetObjectApiNames A list of API names of target objects to search for.
      * @return A list of ObjectMappingTemplate records that map the given source and target objects.
      * Example:
      * [
           {
              "id":"a0068000006PzTVAA0",
              "name":"OpportunityToOrderTemplate",
              "sourceObjectApiName":"Opportunity",
              "targetObjectApiName":"Order"
           }
        ]
   */
    @AuraEnabled(Cacheable=true)
    public static List<ObjectMappingTemplate> getMappingTemplatesByObjectApiNames(List<String> sourceObjectApiNames,
                                                                List<String> targetObjectApiNames){
        return OBJECT_MAPPING_TEMPLATE_SELECTOR.getObjectMappingTemplates(sourceObjectApiNames,
                                                                            targetObjectApiNames);
    }
    /**
      * Returns the ObjectMappingTemplate record with the given ID.
      *
      * @param mappingTemplateId The ID of the ObjectMappingTemplate record to retrieve.
      * @return The ObjectMappingTemplate record with the given ID.
      * Example:
      * {
      *  "id":"a0068000006PzTVAA0",
       "name":"OpportunityToOrderTemplate",
       "sourceObjectApiName":"Opportunity",
       "targetObjectApiName":"Order",
       "fieldMappings":[
          {
             "id":"9827bf2d-ef58-4bcf-ab5f-84a71ebebb53",
             "sourceObjectField":{
                "apiName":"ContractId",
                "labelName":"Contract ID",
                "parentField":{
                   "apiName":"EndDate",
                   "labelName":"Contract End Date",
                   "required":false,
                   "type":"DATE"
                },
                "referenceTo":"Contract",
                "required":false,
                "type":"REFERENCE"
             },
             "targetObjectField":{
                "apiName":"EffectiveDate",
                "labelName":"Order Start Date",
                "required":true,
                "type":"DATE"
             }
          },
          {
             "id":"03b148ec-e99f-4813-b25c-87007e5914e3",
             "sourceObjectField":{
                "apiName":"Description",
                "labelName":"Description",
                "required":false,
                "type":"TEXTAREA"
             },
             "targetObjectField":{
                "apiName":"Description",
                "labelName":"Description",
                "required":false,
                "type":"TEXTAREA"
             }
          }
       ]
    }
    */
    @AuraEnabled(Cacheable=true)
    public static ObjectMappingTemplate getMappingTemplateById(Id mappingTemplateId){
        ObjectUtil.requireNonNull(mappingTemplateId, 'mappingTemplateId cannot be null to retrieve a mapping template.');
        List<ObjectMappingTemplate> objectMappingTemplates =
                OBJECT_MAPPING_TEMPLATE_SELECTOR.getObjectMappingTemplates(new Set<Id>{mappingTemplateId});
        return objectMappingTemplates.isEmpty() ? null : objectMappingTemplates[0];
    }
    /**
      * Upserts the given ObjectMappingTemplate record.
      *
      * @param mappingTemplateJSON The JSON representation of the ObjectMappingTemplate record to upsert.
      * Example:
  * {
           "id":"a0068000006PzTVAA0",
           "sourceObjectApiName":"Opportunity",
           "targetObjectApiName":"Order",
           "name":"OpportunityToOrderTemplate",
           "fieldMappings":[
           {
             "id":"03b148ec-e99f-4813-b25c-87007e5914e3",
             "sourceObjectField":{
                "apiName":"Description",
                "labelName":"Description",
                "required":false,
                "type":"TEXTAREA"
             },
             "targetObjectField":{
                "apiName":"Description",
                "labelName":"Description",
                "required":false,
                "type":"TEXTAREA"
             }
          },
              {
                 "id":"9827bf2d-ef58-4bcf-ab5f-84a71ebebb53",
                 "sourceObjectField":{
                    "apiName":"ContractId",
                    "labelName":"Contract ID",
                    "parentField":{
                       "apiName":"EndDate",
                       "labelName":"Contract End Date",
                       "required":false,
                       "type":"DATE"
                    },
                    "referenceTo":"Contract",
                    "required":false,
                    "type":"REFERENCE"
                 },
                 "targetObjectField":{
                    "apiName":"EffectiveDate",
                    "labelName":"Order Start Date",
                    "required":true,
                    "type":"DATE"
                 }
              },
              {
                 "id":"43785383-8db8-4d99-ba71-910cccb0ad4d",
                 "sourceObjectField":{
                    "apiName":"ContractId",
                    "labelName":"Contract ID",
                    "parentField":{
                       "apiName":"Status",
                       "labelName":"Status",
                       "required":true,
                       "type":"PICKLIST"
                    },
                    "referenceTo":"Contract",
                    "required":false,
                    "type":"REFERENCE"
                 },
                 "targetObjectField":{
                    "apiName":"Status",
                    "labelName":"Status",
                    "required":true,
                    "type":"PICKLIST"
                 }
              }
           ]
        }
      * @return An UpsertTemplateResponse object containing the ID of the upserted ObjectMappingTemplate record.
      * Example:
      * {
      *  "templateId":"a0068000006PzTVAA0"
      * }
     */
    @AuraEnabled
    public static UpsertTemplateResponse upsertMappingTemplate(String mappingTemplateJSON){
        ObjectUtil.requireNonNull(mappingTemplateJSON, 'mappingTemplateJSON cannot be null to upsert a mapping template.');
        ObjectMappingTemplate objectMappingTemplate = (ObjectMappingTemplate) JSON.deserialize(mappingTemplateJSON,ObjectMappingTemplate.class);
        try{
           Id templateId = OBJECT_MAPPING_TEMPLATE_SERVICE.upsertObjectMappingTemplate(objectMappingTemplate);
                return new UpsertTemplateResponse().setTemplateId(templateId);
        }catch (Exception e){
               throw new AuraHandledException(e.getMessage());
        }
    }

    /**
     * Deletes the ObjectMappingTemplate record with the given ID.
     *
     * @param mappingTemplateId The ID of the ObjectMappingTemplate record to delete.
     * @return A string indicating that the ObjectMappingTemplate record was successfully deleted.
     * @throws AuraHandledException If the delete fails.
     */
    @AuraEnabled
    public static String deleteMappingTemplate(Id mappingTemplateId){
        ObjectUtil.requireNonNull(mappingTemplateId, 'mappingTemplateId cannot be null to delete a mapping template.');
        try{
            OBJECT_MAPPING_TEMPLATE_SERVICE.deleteObjectMappingTemplate(mappingTemplateId);
            return 'Object Mapping Template successfully deleted!';
        }catch (Exception e){
            throw new AuraHandledException(e.getMessage());
        }
    }
    /**
        * Response class for the upsertMappingTemplate method.
   */
    public class UpsertTemplateResponse{
        @AuraEnabled public Id templateId;

        public UpsertTemplateResponse setTemplateId(Id templateId) {
            this.templateId = templateId;
            return this;
        }

    }
}