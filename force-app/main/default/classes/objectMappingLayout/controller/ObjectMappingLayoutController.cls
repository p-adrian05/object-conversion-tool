public with sharing class ObjectMappingLayoutController {
    @TestVisible
    private static ObjectMappingLayoutService OBJECT_MAPPING_LAYOUT_SERVICE = new ObjectMappingLayoutServiceImpl();
    @TestVisible
    private static ObjectMappingLayoutsSelector OBJECT_MAPPING_LAYOUT_SELECTOR = new ObjectMappingLayoutsSelector();
    /**
     * @return a list of all the ObjectMappingLayout records with the following fields:
    * Example:
     * [
           {
              "description":"desc",
              "id":"a016800000TBHtCAAX",
              "isDefault":true,
              "name":"oppToOrderLayout"
           }
        ]
     */
    @AuraEnabled(Cacheable=true)
    public static List<ObjectMappingLayout> getMappingLayouts(){
        return OBJECT_MAPPING_LAYOUT_SELECTOR.getObjectMappingLayouts();
    }
    /**
      * Returns the ObjectMappingLayout record with the given ID.
       *
       * @param recordId The ID of the ObjectMappingLayout record to retrieve.
       * @return The ObjectMappingLayout record with the given ID.
       * Example:
       * {
        "id":"a016800000TBHtCAAX",
       "isDefault":false,
       "name":"oppToOrderLayout",
       "parentMapping":{
          "externalId":"35d7a368-ecb2-4a11-b54c-4a72434a1fa5",
          "id":"a0268000003Ge5nAAC",
          "template":{
             "id":"a0068000006PzTVAA0",
             "sourceObjectApiName":"Opportunity",
             "targetObjectApiName":"Order"
          }
       },
       "childMappings":[
          {
             "externalId":"b9f9a8c7-e662-4195-8e1b-f02cf4970cc4",
             "filterState":{
                "customLogicalCondition":"1",
                "filterList":[
                   {
                      "field":{
                         "apiName":"Discount",
                         "labelName":"Discount",
                         "required":false,
                         "type":"PERCENT"
                      },
                      "id":"1678433707892",
                      "index":"1",
                      "operator":"<",
                      "operatorValue":"33"
                   }
                ],
                "filterString":" Discount <  33 ",
                "logicalCondition":"AND"
             },
             "id":"a0268000003H7GxAAK",
             "sourceObjectRelationship":{
                "fieldApiName":"OpportunityId",
                "relationshipName":"OpportunityLineItems"
             },
             "targetObjectRelationship":{
                "fieldApiName":"OrderId",
                "relationshipName":"OrderItems"
             },
             "template":{
                "id":"a0068000006PzaPAAS",
                "sourceObjectApiName":"OpportunityLineItem",
                "targetObjectApiName":"OrderItem"
             }
          },
          {
             "externalId":"bf76e4df-dec0-4637-a7d5-6686aa8ade5f",
             "id":"a0268000003HCZuAAO",
             "sourceObjectRelationship":{

             },
             "targetObjectRelationship":{
                "fieldApiName":"WhatId",
                "relationshipName":"Tasks"
             },
             "template":{
                "id":"a0068000006PyOcAAK",
                "sourceObjectApiName":"Lead",
                "targetObjectApiName":"Task"
             }
          }
       ]
    }
    */
    @AuraEnabled(Cacheable=true)
    public static ObjectMappingLayout getMappingLayout(Id recordId){
        ObjectUtil.requireNonNull(recordId, 'RecordId cannot be null to retrieve ObjectMappingLayout.');
        ObjectMappingLayout objectMappingLayout = OBJECT_MAPPING_LAYOUT_SELECTOR.getObjectMappingLayoutWithObjectMappings(recordId, false);
        return objectMappingLayout;
    }
    /**
     * Upserts the given ObjectMappingLayout record.
     *
     * @param objectMappingLayoutJSON The JSON representation of the ObjectMappingLayout record to upsert.
     * Example:
     * {
           "id":"a016800000TBHtCAAX",
           "name":"oppToOrderLayout",
            "isDefault":false,
           "description":"desc",
           "parentMapping":{
              "id":"a0268000003Ge5nAAC",
              "filterState":null,
              "template":{
                 "id":"a0068000006PzTVAA0",
                 "sourceObjectApiName":"Opportunity",
                 "targetObjectApiName":"Order"
              },
              "externalId":"35d7a368-ecb2-4a11-b54c-4a72434a1fa5"
           },
           "childMappings":[
              {
                 "id":"a0268000003H7GxAAK",
                 "filterState":{
                    "filterList":[
                       {
                          "id":"1678433707892",
                          "index":1,
                          "field":{
                             "apiName":"Discount",
                             "labelName":"Discount",
                             "required":false,
                             "type":"PERCENT"
                          },
                          "operator":"<",
                          "operatorValue":"33"
                       }
                    ],
                    "filterString":" Discount <  33 ",
                    "logicalCondition":"AND",
                    "customLogicalCondition":"1"
                 },
                 "template":{
                    "id":"a0068000006PzaPAAS",
                    "sourceObjectApiName":"OpportunityLineItem",
                    "targetObjectApiName":"OrderItem"
                 },
                 "externalId":"b9f9a8c7-e662-4195-8e1b-f02cf4970cc4",
                 "sourceObjectRelationship":{
                    "relationshipName":"OpportunityLineItems",
                    "fieldApiName":"OpportunityId"
                 },
                 "targetObjectRelationship":{
                    "relationshipName":"OrderItems",
                    "fieldApiName":"OrderId"
                 }
              }
           ]
        }
     * @return The ID of the upserted ObjectMappingLayout record wrapped in an UpsertLayoutResponse object.
     * Example:
     * {
           "layoutId":"a016800000TBHtCAAX"
        }
     */
    @AuraEnabled
    public static UpsertLayoutResponse upsertMappingLayout(String objectMappingLayoutJSON){
        ObjectUtil.requireNonNull(objectMappingLayoutJSON, 'ObjectMappingLayoutJSON cannot be null to upsert a layout');
        ObjectMappingLayout objectMappingLayout = (ObjectMappingLayout) JSON.deserialize(objectMappingLayoutJSON,ObjectMappingLayout.class);

        UpsertLayoutResponse upsertTemplateResponse = new UpsertLayoutResponse();
        try{
            Id objectMappingLayoutId = OBJECT_MAPPING_LAYOUT_SERVICE.upsertObjectMappingLayout(objectMappingLayout);
            upsertTemplateResponse.layoutId = objectMappingLayoutId;
        }catch (Exception e){
            System.debug(e.getMessage());
            throw new AuraHandledException(e.getMessage());
        }
        return upsertTemplateResponse;
    }
    /**
      * Deletes the ObjectMappingLayout record with the given ID.
      *
      * @param layoutId The ID of the ObjectMappingLayout record to delete.
      * @return A string indicating the success of the operation.
    */
    @AuraEnabled
    public static String deleteMappingLayout(Id layoutId){
        ObjectUtil.requireNonNull(layoutId, 'LayoutId cannot be null to delete a layout');
        try{
            OBJECT_MAPPING_LAYOUT_SERVICE.deleteObjectMappingLayout(layoutId);
        }catch (Exception e){
            System.debug(e.getMessage());
            throw new AuraHandledException(e.getMessage());
        }
        return 'Layout successfully deleted!';
    }
    /**
    * Returns a list of all the ObjectMappingLayout records for the given source record ID type.
    *
    * @param sourceRecordId The ID of the source record.
    * @return A list of ObjectMappingLayout records for the given source record ID type.
     * Example:
     * [
           {
              "description":"desc",
              "id":"a016800000TBHtCAAX",
              "isDefault":true,
              "name":"oppToOrderLayout"
           }
        ]
    */
    @AuraEnabled(Cacheable=true)
    public static List<ObjectMappingLayout> getObjectMappingLayoutsBySourceRecordId(Id sourceRecordId){
        if(sourceRecordId == null) {
            return new List<ObjectMappingLayout>();
        }
        return OBJECT_MAPPING_LAYOUT_SELECTOR
              .getObjectMappingLayoutsByParentSourceObject(sourceRecordId.getSobjectType().getDescribe().getName());
    }
    /**
    * Marks the ObjectMappingLayout record with the given ID as the default layout for its object type.
    *
    *  @param objectMappingLayoutId The ID of the ObjectMappingLayout record to mark as default.
     * @return A string indicating the success of the operation.
    */
    @AuraEnabled
    public static String markDefaultLayout(Id objectMappingLayoutId){
        ObjectUtil.requireNonNull(objectMappingLayoutId, 'ObjectMappingLayoutId cannot be null to mark a layout as default');
        try{
            OBJECT_MAPPING_LAYOUT_SERVICE.markDefaultObjectMappingLayout(objectMappingLayoutId);
        }catch (Exception e){
            System.debug(e.getMessage());
            throw new AuraHandledException(e.getMessage());
        }
        return 'Layout successfully set to default on '+objectMappingLayoutId.getSobjectType().getDescribe().getName()
                +' '+ objectMappingLayoutId;
    }
    /**
      * Response class for the upsertMappingLayout method.
    */
    public class UpsertLayoutResponse{
        @AuraEnabled public Id layoutId;
    }



}