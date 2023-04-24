public with sharing class ObjectMappingLayoutConverterServiceImpl implements ObjectMappingLayoutConverterService {

    private final ObjectMappingTemplateConverter objectMappingTemplateConverter;

    public ObjectMappingLayoutConverterServiceImpl(ObjectMappingTemplateConverter objectMappingTemplateConverter){
        ObjectUtil.requireNonNull(objectMappingTemplateConverter,'objectMappingTemplateConverter cannot be null!');
        this.objectMappingTemplateConverter = objectMappingTemplateConverter;
    }
    /**
         Converts an SObject record and its related records using the specified object mapping layout.

         @param sourceRecordId the ID of the source record to be converted
         @param objectMappingLayoutId the ID of the object mapping layout to be used for the conversion
         @param objectMappingLayoutSelector the object mapping layout selector to be used to retrieve the object mapping layout
         @return an ObjectConversionResult object that contains the converted parent record and a list of converted related child records.
     */
    public ObjectConversionResult convertObject(Id sourceRecordId,Id objectMappingLayoutId, ObjectMappingLayoutsSelector objectMappingLayoutSelector){
        ObjectUtil.requireNonNull(sourceRecordId,'sourceRecordId cannot be null to convert an object!');
        ObjectUtil.requireNonNull(objectMappingLayoutId,'objectMappingLayoutId cannot be null to convert an object!');
        ObjectUtil.requireNonNull(objectMappingLayoutSelector,'objectMappingLayoutService cannot be null!');

        ObjectMappingLayout objectMappingLayout = new SelectObjectMappingLayout()
                .selectObjectMappingLayout(objectMappingLayoutSelector,objectMappingLayoutId);

        ObjectUtil.requireNonNull(objectMappingLayout,'No object mapping layout found for id: '+objectMappingLayoutId);
        return convertObject(sourceRecordId,objectMappingLayout);
    }
    private without sharing class SelectObjectMappingLayout{
        public ObjectMappingLayout selectObjectMappingLayout(ObjectMappingLayoutsSelector objectMappingLayoutSelector, Id objectMappingLayoutId) {
            return objectMappingLayoutSelector.getObjectMappingLayoutWithObjectMappings(objectMappingLayoutId,true);
        }
    }

    /**
       Converts an SObject record and its related records using the specified object mapping layout.

        @param sourceRecordId the ID of the source record to be converted
        @param objectMappingLayout - The object mapping layout that defines how the source record should be converted.
        @return an ObjectConversionResult object that contains the converted parent record and a list of converted related child records.
    */
    public ObjectConversionResult convertObject(Id sourceRecordId,ObjectMappingLayout objectMappingLayout){
        ObjectUtil.requireNonNull(sourceRecordId,'sourceRecordId cannot be null to convert an object!');
        validateObjectMappingLayout(objectMappingLayout);
        //convert parent record
        SObject parentTargetRecord = convertParentRecord(sourceRecordId,objectMappingLayout.parentMapping);
        ObjectUtil.requireNonNull(parentTargetRecord,'Failed to convert parent record! (Or you dont have access to the record!) ' +
                'No record found for object mapping layout: '
                +objectMappingLayout.id + ' and source record id: '+sourceRecordId);
        if(!parentTargetRecord.getSObjectType().getDescribe().isCreateable()){
            throw new SObjectException('Do not have permission to create object:' +
                    ' '+parentTargetRecord.getSObjectType().getDescribe().getName()+'!');
        }
        Savepoint savepoint = Database.setSavepoint();
        List<SObject> relatedRecords = new List<SObject>();
        try{
            insert parentTargetRecord;
            relatedRecords = convertRelatedRecords(sourceRecordId,parentTargetRecord.Id,objectMappingLayout.childMappings);
            insert relatedRecords;
        }catch (Exception e){
            Database.rollback(savepoint);
            throw e;
        }
        return new ObjectConversionResult(parentTargetRecord,relatedRecords);
    }
    private SObject convertParentRecord(Id parentRecordId,ObjectMapping parentObjectMapping){
        List<SObject> parentTargetRecord = this.objectMappingTemplateConverter
                .convertRecords(new List<Id>{parentRecordId},parentObjectMapping.template).values();

        if(!parentTargetRecord.isEmpty()){
            return parentTargetRecord.get(0);
        }
        return null;
    }

    /**
    Converts the child records of the specified source parent record to target records based on the specified
     child object mappings, and associates them with the specified parent target record.

    @param sourceParentRecordId The ID of the source parent record whose child records to convert.
    @param targetParentRecordId The ID of the target parent record to associate the converted child records with.
    @param childObjectMappings A list of object mappings that define the relationships and fields to convert.
    @return A list of the converted child records as target SObjects.
*/
    @TestVisible
    private List<SObject> convertRelatedRecords(Id sourceParentRecordId,Id targetParentRecordId,List<ObjectMapping> childObjectMappings){
        List<SObject> relatedTargetRecordsToInsert = new List<SObject>();
        //convert related records
        List<RelatedObject> relatedSourceRecords = getRelatedSourceRecords(sourceParentRecordId,childObjectMappings);
        List<RelatedObject> relatedTargetRecords = convertToRelatedTargetRecords(relatedSourceRecords);
        //set parent record id on related records
        for(RelatedObject relatedTargetObject:relatedTargetRecords){
            for(SObject relatedTargetRecord:relatedTargetObject.records){
                relatedTargetRecord.put(relatedTargetObject.objectMapping.targetObjectRelationship.fieldApiName,targetParentRecordId);
                relatedTargetRecordsToInsert.add(relatedTargetRecord);
            }
        }
        return relatedTargetRecordsToInsert;
    }
    /**
    Converts a list of RelatedObject sourceObjects to a List of RelatedObject targetObjects.
        Each RelatedObject contains the object mapping and a list of converted related target records.

    @param relatedSourceObjects A list of RelatedObject objects,
         where each RelatedObject contains the object mapping and a list of related source records.
    @return A list of RelatedObject objects,
        where each RelatedObject contains the object mapping and a list of converted related target records.
    */
   private List<RelatedObject> convertToRelatedTargetRecords(List<RelatedObject> relatedSourceObjects){
        List<RelatedObject> relatedTargetObjects = new List<RelatedObject>();
        if (relatedSourceObjects == null || relatedSourceObjects.size() == 0) {
            return relatedTargetObjects;
        }
        for(RelatedObject sourceObject:relatedSourceObjects){
            List<SObject> relatedSourceRecords = sourceObject.records;
            ObjectMapping objectMapping = sourceObject.objectMapping;

            validateChildObjectMapping(objectMapping);
            if(relatedSourceRecords==null || relatedSourceRecords.isEmpty()){
               continue;
            }
            //convert related source records to target records
            List<SObject> relatedTargetRecords = this.objectMappingTemplateConverter
                                        .convertRecords(relatedSourceRecords,sourceObject.objectMapping.template).values();
            relatedTargetObjects.add(new RelatedObject(objectMapping,relatedTargetRecords));
        }
        return relatedTargetObjects;
    }
    @TestVisible
    private List<RelatedObject> getRelatedSourceRecords(Id parentRecordId,List<ObjectMapping> childObjectMappings){
        List<RelatedObject> relatedObjects = new  List<RelatedObject>();
        if (parentRecordId == null || childObjectMappings == null || childObjectMappings.isEmpty()) {
            return relatedObjects;
        }
        for(ObjectMapping childObjectMapping:childObjectMappings){
          List<SObject> relatedRecords = queryRelatedSourceRecords(parentRecordId,childObjectMapping);
          if(!relatedRecords.isEmpty()){
              relatedObjects.add(new RelatedObject(childObjectMapping,relatedRecords));
          }
        }
        return relatedObjects;
    }

    /**
        Queries related records for a parent record based on the specified object mapping.

        @param sourceParentRecordId The ID of the parent record for which to query related records.
        @param objectMapping The object mapping that defines the relationship and fields to retrieve.
        @return A list of related SObjects.
    */
    private List<SObject> queryRelatedSourceRecords(Id sourceParentRecordId,ObjectMapping objectMapping){
        ObjectUtil.requireNonNull(sourceParentRecordId,'sourceParentRecordId cannot be null!');
        validateChildObjectMapping(objectMapping);

        List<SObject> relatedRecords = new List<SObject>();
        Map<String,Object> objectFilterBinds = new Map<String,Object>{'sourceParentRecordId' => sourceParentRecordId};
        String objectFilterString;

        ObjectRelationship sourceObjectRelationship = objectMapping.sourceObjectRelationship;
        String sourceObjectApiName = objectMapping.template.sourceObjectApiName;
        String sourceObjectFieldApiNames = String.join(objectMapping.template.getSourceObjectFieldApiNames(),',');

        if(objectMapping.filterState!=null){
            objectFilterString = objectMapping.filterState.filterStringWithBinds;
            objectFilterBinds.putAll(objectMapping.filterState.getBindVariables());
        }

        //build query string
        String queryStr = 'SELECT '+sourceObjectFieldApiNames + ' FROM '+sourceObjectApiName+' ' +
                'WHERE '+sourceObjectRelationship.fieldApiName+'=:sourceParentRecordId ';
        //add filter string if specified
        if(objectFilterString!=null && objectFilterString.trim()!=''){
            if(objectFilterBinds.size()==1){
                throw new SObjectException('Filters must contain at least one bind variable! '+objectFilterString);
            }
            queryStr += ' AND ('+String.escapeSingleQuotes(objectFilterString)+')';
        }
        System.debug('Related records query: '+queryStr);
        System.debug('Bind variables map: '+objectFilterBinds);
        for(SObject sourceRecord:ObjectUtil.executeQueryWithoutSharing(queryStr,objectFilterBinds)){
            relatedRecords.add(sourceRecord);
        }
        return relatedRecords;
    }
    @TestVisible
    class RelatedObject {
        public List<SObject> records;
        public ObjectMapping objectMapping;
        public RelatedObject(ObjectMapping objectMapping,List<SObject> records){
            this.objectMapping = objectMapping;
            this.records = records;
        }
    }
    private void validateObjectMappingLayout(ObjectMappingLayout objectMappingLayout){
        ObjectUtil.requireNonNull(objectMappingLayout,'ObjectMappingLayout cannot be null!');
        ObjectUtil.requireNonNull(objectMappingLayout.parentMapping,'ObjectMappingLayout parent mapping cannot be null!');
        ObjectUtil.requireNonNull(objectMappingLayout.parentMapping.template,'ObjectMappingLayout parent mapping template cannot be null!');
    }
    private void validateChildObjectMapping(ObjectMapping objectMapping){
        ObjectUtil.requireNonNull(objectMapping,'ObjectMapping cannot be null!');
        ObjectUtil.requireNonNull(objectMapping.template,'ObjectMapping template cannot be null!');
        ObjectUtil.requireNonNull(objectMapping.template.sourceObjectApiName,'ObjectMapping template source object API name cannot be null!');
        ObjectUtil.requireNonNull(objectMapping.template.targetObjectApiName,'ObjectMapping template target object API name cannot be null!');

        if(objectMapping.sourceObjectRelationship?.fieldApiName==null
                || objectMapping.targetObjectRelationship?.fieldApiName==null){
            throw new IllegalArgumentException('Invalid object relationship found on object template: '
                    +objectMapping.template.name+'!'+
                    +objectMapping.sourceObjectRelationship+' => '+objectMapping.targetObjectRelationship);
        }
    }

}