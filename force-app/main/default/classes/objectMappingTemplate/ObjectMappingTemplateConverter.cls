public interface ObjectMappingTemplateConverter {
    /**
       * Convert given records to other records based on the mapping setup.
       *
       * @param sourceRecordIds list of source records from the created records will derived from
       * @param objectMappingTemplate The object mapping template used to map source fields to target fields.
       *  @return a map containing the created records, where the keys of the map are the IDs of the source records
       *         and the values are the created records themselves.
       */
     Map<Id, SObject> convertRecords(List<Id> sourceRecordIds,ObjectMappingTemplate objectMappingTemplate);
    /**
        Converts a list of source records to a map of target records using the provided object mapping template.
        @param sourceRecords The list of source records to be converted.
        @param objectMappingTemplate The object mapping template used to map source fields to target fields.

        @return a map containing the created records, where the keys of the map are the IDs of the source records
               and the values are the created records themselves.
        @throws SObjectException If a source or target field name is null or empty in the object mapping template.
    */
     Map<Id, SObject> convertRecords(List<SObject> sourceRecords,ObjectMappingTemplate objectMappingTemplate);

}