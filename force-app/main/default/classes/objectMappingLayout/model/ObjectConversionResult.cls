public with sharing class ObjectConversionResult {

    public SObject parentRecord;
    public List<SObject> relatedRecords;

    public ObjectConversionResult(SObject parentRecord, List<SObject> relatedRecords) {
        this.parentRecord = parentRecord;
        this.relatedRecords = relatedRecords;
    }
}