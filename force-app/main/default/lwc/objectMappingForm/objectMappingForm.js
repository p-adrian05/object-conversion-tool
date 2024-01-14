import {api,wire, LightningElement, track} from 'lwc';
import getSObjects from '@salesforce/apex/ObjectUtilController.getSObjects';
import {reduceErrors, showErrorMessage} from "c/errorHandlingUtils";
import {refreshApex} from "@salesforce/apex";
import getMappingTemplateById from '@salesforce/apex/ObjectMappingTemplateController.getMappingTemplateById';

const DESCRIPTION_TEXTAREA_PLACEHOLDER = 'Description';
const SOURCE_OBJECT_SELECTOR_LABEL = 'Source Object';
const TARGET_OBJECT_SELECTOR_LABEL = 'Target Object';
const SOURCE_OBJECT_SELECTOR_PLACEHOLDER = 'Select Object';
const TARGET_OBJECT_SELECTOR_PLACEHOLDER = 'Select Object';
export default class ObjectMappingForm extends LightningElement {

    labels={
        descriptionTextAreaPlaceholder:DESCRIPTION_TEXTAREA_PLACEHOLDER,
        sourceObjectSelectorLabel:SOURCE_OBJECT_SELECTOR_LABEL,
        targetObjectSelectorLabel:TARGET_OBJECT_SELECTOR_LABEL,
        sourceObjectSelectorPlaceholder:SOURCE_OBJECT_SELECTOR_PLACEHOLDER,
        targetObjectSelectorPlaceholder:TARGET_OBJECT_SELECTOR_PLACEHOLDER
    }

    isLoading;
    @api objectMappingTemplateId;
    @api objectMappingTemplateRecord;
    @api selectedSourceObjectApiName;
    @api selectedTargetObjectApiName;
    @api readOnly = false
    @track sourceObjectOptions;
    @track targetObjectOptions;
    @track error;
    @track fieldMappingDataList = [];
    @api mappingTemplateDescription;
    @api hideFieldMappings = false;

    objectOptionsCache = [];
    sourceObjectApiNamesCache = [];
    targetObjectApiNamesCache = [];
    mappingTemplateResponse;

    @wire(getMappingTemplateById,{mappingTemplateId:'$objectMappingTemplateId'})
    getTemplateRecord(response){
        if(response.data){
            this.mappingTemplateResponse = response;
            this.objectMappingTemplateRecord = response.data;

            this.selectedSourceObjectApiName = this.objectMappingTemplateRecord.sourceObjectApiName;
            this.selectedTargetObjectApiName = this.objectMappingTemplateRecord.targetObjectApiName;
            this.fieldMappingDataList = [...this.objectMappingTemplateRecord.fieldMappings];
            this.mappingTemplateDescription = this.objectMappingTemplateRecord.description;

            this.notifyLoadTemplateRecord();
        }else if(response.error){
            this.error = reduceErrors(response.error);
            showErrorMessage(this.error);
            console.error(JSON.stringify(this.error));
        }
        this.isLoading = false;
        this.notifyLoading(this.isLoading);
    }
    @api get targetObjectApiNames(){
        return this.targetObjectApiNamesCache;
    }
    set targetObjectApiNames(apiNames){
        this.targetObjectApiNamesCache = apiNames;
        this.targetObjectOptions = this.filterOutOptionsFromArray(this.objectOptionsCache,apiNames);

    }
    @api get sourceObjectApiNames(){
       return this.sourceObjectApiNamesCache;
    }
    set sourceObjectApiNames(apiNames){
        this.sourceObjectApiNamesCache = apiNames;
        this.sourceObjectOptions = this.filterOutOptionsFromArray(this.objectOptionsCache,apiNames);
    }
    @wire(getSObjects)
    initSObjects({error,data}) {
        if (data) {
            let objectOptions = data.map(object => {
                return {
                    label: object.label,
                    value: object.objectApiName
                }
            });
            this.objectOptionsCache = objectOptions;

            this.sourceObjectOptions = this.filterOutOptionsFromArray(this.objectOptionsCache,this.sourceObjectApiNames);
            this.targetObjectOptions = this.filterOutOptionsFromArray(this.objectOptionsCache,this.targetObjectApiNames);
        }else if(error){
            this.error = reduceErrors(error);
            showErrorMessage(this.error);
            console.error(JSON.stringify(this.error));
        }
        this.isLoading = false;
        this.notifyLoading(this.isLoading);
    }

    filterOutOptionsFromArray(originalArray,arrayForFilter){
        return originalArray.filter(option=>{
            if(arrayForFilter && arrayForFilter.length>0){
                if(arrayForFilter.includes(option.value)){
                    return true;
                }else {
                    return false;
                }
            }else {
                return true;
            }
        });
    }

    get initRequiredFields(){
        return !this.objectMappingTemplateId;
    }

    connectedCallback() {
        this.isLoading = true;
        this.notifyLoading(this.isLoading);

    }

    get showFieldMappings(){
        return this.selectedTargetObjectApiName && this.selectedTargetObjectApiName && !this.hideFieldMappings;
    }

    @api validate(){
        let isValid =  this.template.querySelector('c-object-field-mappings').validate();
        if(!this.selectedSourceObjectApiName || !this.selectedTargetObjectApiName){
            isValid = false;
        }
        return isValid;
    }

     @api
     refreshCachedData(recordId) {
        this.isLoading = true;
        this.notifyLoading(this.isLoading);
        this.objectMappingTemplateId = recordId;
        refreshApex(this.mappingTemplateResponse);
    }
    @api loadTemplate(objectMappingTemplateId){
        this.isLoading = true;
        this.notifyLoading(this.isLoading);
        this.objectMappingTemplateId = objectMappingTemplateId;

    }
    @api removeTemplate(){
        this.objectMappingTemplateId = undefined;
        this.objectMappingTemplateRecord = undefined;
        this.selectedSourceObjectApiName = undefined;
        this.selectedTargetObjectApiName = undefined;
        this.mappingTemplateDescription = undefined;
        this.fieldMappingDataList = [];
    }
    @api restoreFieldMappings(){
        this.fieldMappingDataList = [...this.fieldMappingDataList];
    }
    @api
    getFieldMappingJSONState(){
       return JSON.stringify(this.template.querySelector('c-object-field-mappings').getFieldMappingDataList());
    }
    @api
    getFieldMappings(){
        return this.template.querySelector('c-object-field-mappings').getFieldMappingDataList();
    }
    handleMappingTemplateDescriptionChange(event){
        this.mappingTemplateDescription = event.detail.value;
    }

    handleSourceObjectChange(event) {
        this.selectedSourceObjectApiName = event.detail.value;
    }
    handleTargetObjectChange(event) {
        this.selectedTargetObjectApiName = event.detail.value;
    }
    notifyLoading(isLoading) {
        if (isLoading) {
            this.dispatchEvent(new CustomEvent('loading'));
        } else {
            this.dispatchEvent(new CustomEvent('doneloading'));
        }
    }
    notifyLoadTemplateRecord(){
        const templateRecordLoadedEvent= new CustomEvent('mappingtemplateloaded',{
            detail:this.objectMappingTemplateId
        });
        this.dispatchEvent(templateRecordLoadedEvent);
    }


}