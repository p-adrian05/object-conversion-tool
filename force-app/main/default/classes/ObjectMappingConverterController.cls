public with sharing class ObjectMappingConverterController {
    @TestVisible
    private static ObjectMappingTemplateConverter OBJECT_MAPPING_TEMPLATE_CONVERTER = new ObjectMappingTemplateConverterImpl();
    @TestVisible
    private static ObjectMappingLayoutsSelector OBJECT_MAPPING_LAYOUT_SELECTOR = new ObjectMappingLayoutsSelector();
    @TestVisible
    private static ObjectMappingLayoutConverterService OBJECT_MAPPING_LAYOUT_CONVERTER_SERVICE =
                                        new ObjectMappingLayoutConverterServiceImpl(OBJECT_MAPPING_TEMPLATE_CONVERTER);

    /**
     * Converts the source record using the ObjectMappingLayout record with the given ID.
     *
     * @param sourceRecordId The ID of the source record to convert.
     * @param objectMappingLayoutId The ID of the ObjectMappingLayout record to use for conversion.
     * @return The ID of the converted record, or null if no records were converted.
     */
    @AuraEnabled
    public static Id convertObjectFromLayout(Id sourceRecordId, Id objectMappingLayoutId) {
        ObjectUtil.requireNonNull(sourceRecordId, 'SourceRecordId cannot be null to convert an object!');
        ObjectUtil.requireNonNull(objectMappingLayoutId, 'ObjectMappingLayoutId cannot be null to convert an object!');
        try{
            ObjectConversionResult conversionResult = OBJECT_MAPPING_LAYOUT_CONVERTER_SERVICE.convertObject(sourceRecordId,
                    objectMappingLayoutId,OBJECT_MAPPING_LAYOUT_SELECTOR);
            return conversionResult.parentRecord?.Id;
        }catch (Exception e){
            System.debug(e.getMessage());
            throw new AuraHandledException(e.getMessage());
        }
    }
}