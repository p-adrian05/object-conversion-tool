public interface ObjectMappingLayoutConverterService {
    /**
        Converts an SObject record and its related records using the specified object mapping layout.

        @param sourceRecordId the ID of the source record to be converted
        @param objectMappingLayoutId the ID of the object mapping layout to be used for the conversion
        @param objectMappingLayoutSelector the object mapping layout selector to be used to retrieve the object mapping layout
        @return an ObjectConversionResult object that contains the converted parent record and a list of converted related child records.
    */
    ObjectConversionResult convertObject(Id sourceRecordId,Id objectMappingLayoutId, ObjectMappingLayoutsSelector objectMappingLayoutSelector);
    /**
       Converts an SObject record and its related records using the specified object mapping layout.

        @param sourceRecordId the ID of the source record to be converted
        @param objectMappingLayout - The object mapping layout that defines how the source record should be converted.
      @return an ObjectConversionResult object that contains the converted parent record and a list of converted related child records.
    */
    ObjectConversionResult convertObject(Id sourceRecordId,ObjectMappingLayout objectMappingLayout);
}