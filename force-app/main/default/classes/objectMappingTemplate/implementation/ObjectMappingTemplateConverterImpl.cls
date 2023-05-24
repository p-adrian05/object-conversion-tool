public with sharing class ObjectMappingTemplateConverterImpl implements ObjectMappingTemplateConverter {

    /**
         * Convert given records to other records based on the mapping setup.
         *
         * @param sourceRecordIds list of source records from the created records will derived from
         * @param objectMappingTemplate The object mapping template used to map source fields to target fields.
         *  @return a map containing the created records, where the keys of the map are the IDs of the source records
         *         and the values are the created records themselves.
     */
    public Map<Id, SObject> convertRecords(List<Id> sourceRecordIds,ObjectMappingTemplate objectMappingTemplate) {
        if (sourceRecordIds == null || sourceRecordIds.size() == 0) {
            return new Map<Id, SObject>();
        }
        validateMappingTemplate(objectMappingTemplate);
        List<SObject> sourceRecords = querySourceRecords(sourceRecordIds,objectMappingTemplate);
        return convertRecords(sourceRecords,objectMappingTemplate);
    }

    /**
     Converts a list of source records to a map of target records using the provided object mapping template.
     @param sourceRecords The list of source records to be converted.
     @param objectMappingTemplate The object mapping template used to map source fields to target fields.

     @return a map containing the created records, where the keys of the map are the IDs of the source records
            and the values are the created records themselves.
 */
    public Map<Id, SObject> convertRecords(List<SObject> sourceRecords,ObjectMappingTemplate objectMappingTemplate) {
        ObjectUtil.requireNonEmpty(sourceRecords, 'Source Records cannot be empty!');
        Map<Id, SObject> sourceRecordIdTargetRecordMap = new Map<Id, SObject>();
        validateMappingTemplate(objectMappingTemplate);

        for (SObject sourceRecord : sourceRecords) {
            // Create a new target record
            SObject targetRecord = (SObject) System.Type.forName(objectMappingTemplate.targetObjectApiName)
                    .newInstance();
            //System.debug('Source Record: ' + sourceRecord.Id);
            // Map the source fields to the target fields
            for (FieldMapping fieldMapping : objectMappingTemplate.fieldMappings) {
                validateFieldMapping(fieldMapping);

                String sourceFieldName = fieldMapping.sourceObjectField.toSOQLFieldName();
                String targetFieldName = fieldMapping.targetObjectField.toSOQLFieldName();

                //System.debug('Source Field: ' + sourceFieldName + ' Target Field: ' + targetFieldName);
                // Get the value of the source field
                Object sourceFieldValue = getFieldValueFromSObject(sourceFieldName,sourceRecord);
                //System.debug('Source Field Value: ' + sourceFieldValue);
                // Set the value of the target field
                targetRecord.put(targetFieldName,sourceFieldValue);
            }
            sourceRecordIdTargetRecordMap.put(sourceRecord.Id, targetRecord);
        }
        return sourceRecordIdTargetRecordMap;
    }

    /**
        Retrieves the value of a field from an SObject record. The field parameter specifies a dot notation path
        to the field's location within the SObject record.
        @param field The dot notation path to the field's location.
        @param record The SObject record containing the field.
        @return The value of the specified field in the SObject record.
*/
    @TestVisible
    private Object getFieldValueFromSObject(String field,SObject record){
        List<String> sourceRecordQueryFields = field.split('\\.');

        Object currentValueObject;
        SObject currentSObject = record;

        for(Integer i = 0; i<sourceRecordQueryFields.size();i++){
            if(currentSObject!=null){
                if(i == sourceRecordQueryFields.size()-1){
                    currentValueObject = currentSObject.get(sourceRecordQueryFields.get(i));
                }else{
                    currentSObject = currentSObject.getSObject(sourceRecordQueryFields.get(i));
                }
            }

        }
        return currentValueObject;
    }

    @TestVisible
    private List<SObject> querySourceRecords(List<Id> sourceRecordIds,ObjectMappingTemplate objectMappingTemplate){
        //validate record types
        for(Id sourceRecordId: sourceRecordIds){
            if(!sourceRecordId.getSobjectType().getDescribe().getName().equals(objectMappingTemplate.sourceObjectApiName)){
                throw new IllegalArgumentException('Invalid record to convert: Source record type: '
                        +sourceRecordId.getSobjectType().getDescribe().getName()
                        +' is different from the source object type:'
                        +objectMappingTemplate.sourceObjectApiName + ' presented in the given template :'+ objectMappingTemplate);
            }
        }
        //build the query string
        List<String> sourceRecordFields = objectMappingTemplate.getSourceObjectFieldApiNames();

        String queryStr = 'SELECT ' + String.join(sourceRecordFields,',') +
                ' FROM '+objectMappingTemplate.sourceObjectApiName +
                ' WHERE Id IN:sourceRecordIds';
        System.debug('Query Source record string: ' + queryStr);
        return Database.query(queryStr);
    }
    private void validateMappingTemplate(ObjectMappingTemplate objectMappingTemplate){
        ObjectUtil.requireNonNull(objectMappingTemplate, 'ObjectMappingTemplate is null!' +
                ' Please provide a valid ObjectMappingTemplate.');
        ObjectUtil.requireNonNull(objectMappingTemplate.sourceObjectApiName, 'Source Object API Name is null!');
        ObjectUtil.requireNonNull(objectMappingTemplate.targetObjectApiName, 'Target Object API Name is null!');
        ObjectUtil.requireNonEmpty(objectMappingTemplate.fieldMappings, 'Field Mappings are empty!');
    }
    private void validateFieldMapping(FieldMapping fieldMapping){
        ObjectUtil.requireNonNull(fieldMapping, 'FieldMapping is null!');
        ObjectUtil.requireNonNull(fieldMapping.sourceObjectField, 'Source Object Field is null on FieldMapping: ' + fieldMapping);
        ObjectUtil.requireNonNull(fieldMapping.targetObjectField, 'Target Object Field is null on FieldMapping: ' + fieldMapping);
        String sourceFieldApiName= fieldMapping.sourceObjectField.apiName;
        String targetFieldApiName = fieldMapping.targetObjectField.apiName;
        ObjectUtil.requireNonNull(sourceFieldApiName, 'Source Object Field Name is null on  FieldMapping: ' + fieldMapping);
        ObjectUtil.requireNonNull(targetFieldApiName, 'Target Object Field Name is null on  FieldMapping: ' + fieldMapping);

    }
}