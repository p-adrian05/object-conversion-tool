import {api, LightningElement, track, wire} from 'lwc';
import getFieldsBySobjectApiName from '@salesforce/apex/ObjectUtilController.getFieldsBySobjectApiName';
import {reduceErrors, showErrorMessage} from "c/errorHandlingUtils";

const OPEN_BUTTON_ICON_NAME = 'utility:up';
const CLOSE_BUTTON_ICON_NAME = 'utility:down';
const REQUIRED_FIELDS_TO_EXCLUDE = ['Id', 'CreatedDate', 'CreatedById', 'LastModifiedDate', 'LastModifiedById',
    'SystemModstamp', 'LastActivityDate', 'LastViewedDate', 'LastReferencedDate', 'IsDeleted',
    'MasterRecordId', 'IsClosed', 'IsEscalated', 'IsSelfServiceClosed', 'IsSelfServiceEscalated',
    'IsSelfServiceResolved', 'IsSelfServiceUnresolved', 'IsUnreadByOwner','OwnerId'];
export default class ObjectFieldMappings extends LightningElement {

    openCloseButtonIconName = OPEN_BUTTON_ICON_NAME;
    @track mappingFieldsVisible = true;

    isLoading;

    @api sourceObjectApiName;
    @api targetObjectApiName;
    @track fieldMappingDataMap = [];
    @track sourceObjectFields = [];
    @track targetObjectFields = [];

    @api initRequiredFields = false;

    @api
    get fieldMappingDataList(){
        return this.fieldMappingDataMap;
    }
    set fieldMappingDataList(fieldMappingDataList){
       this.fieldMappingDataMap = [];
        if(Array.isArray(fieldMappingDataList)) {
            fieldMappingDataList.forEach((fieldMappingData) => {
                this.fieldMappingDataMap.push({key:fieldMappingData.id,value:Object.assign({},fieldMappingData)})});
        }
    }

    @api
    getFieldMappingDataList(){
        return this.fieldMappingDataList.map(fieldMappingData=>{
            return fieldMappingData.value;
        });
    }
    @api validate(){
        let isValid = true;
        let inputFields = this.template.querySelectorAll('c-object-field-mapping');
        inputFields.forEach(inputField =>{
            if(!inputField.validate()) {
                isValid = false;
            }
        });
        return isValid;
    }

    @track errors;
    @wire(getFieldsBySobjectApiName,{sObjectApiName: '$sourceObjectApiName',isFormulaIncluded:'true'})
    initConvertFromFields({error,data}){
        if(data){
            this.sourceObjectFields = data;
        }else if(error){
            this.sourceObjectFields = [];
            this.errors = reduceErrors(error);
            showErrorMessage(this.errors);
        }
    }
    @wire(getFieldsBySobjectApiName,{sObjectApiName: '$targetObjectApiName',isFormulaIncluded:'false'})
    initConvertToFields({error,data}){
        if(data){
            this.targetObjectFields = data;

            if(this.initRequiredFields){
                this.initializeRequiredToFields(this.targetObjectFields);
            }

        }else if(error){
            this.targetObjectFields = [];
            this.errors = reduceErrors(error);
            showErrorMessage(this.errors);
        }
    }

    handleFieldMappingDataChange(event){
        let changedFieldMappingData = event.detail.fieldMappingData;
        this.fieldMappingDataList.forEach(fieldMappingData=>{
             if(fieldMappingData.key === changedFieldMappingData.id){
                 fieldMappingData.value = changedFieldMappingData;
             }
         });

    }
    //remove the selected fieldMappingData by ID from fieldMappingDataList array
    // and reassign it for trigger rerendering
    handleFieldMappingDataDelete(event){
        this.removeFieldMappingDataById(event.detail.fieldMappingDataId);
        this.fieldMappingDataMap = [...this.fieldMappingDataList];
    }

    removeFieldMappingDataById(id){
        if(id && this.fieldMappingDataList){
            let indexToDelete = this.fieldMappingDataList.findIndex(fieldMappingData=>fieldMappingData.key === id);
            return this.fieldMappingDataList.splice(indexToDelete,1);
        }
        return null;
    }

    handleAddFieldMappingButtonClicked(event){
        let emptyFieldMappingData = new FieldMappingData();
        this.fieldMappingDataList.unshift({key:emptyFieldMappingData.id,value:emptyFieldMappingData});
    }


    initializeRequiredToFields(fields){
        this.fieldMappingDataList = [];
        if(Array.isArray(fields)){
            fields.filter(field=>field.required && !REQUIRED_FIELDS_TO_EXCLUDE.includes(field.apiName)).forEach(field=>{
                let emptyFieldMappingData = new FieldMappingData();
                emptyFieldMappingData.targetObjectField = field;
                this.fieldMappingDataList.push({key:emptyFieldMappingData.id,value:emptyFieldMappingData});
            })
        }

    }



    handleCloseMappingButtonClicked(event){
        if (!this.mappingFieldsVisible) {
            this.openMappingFieldsLayout();
        } else {
            this.closeMappingFieldsLayout();
        }
    }

    openMappingFieldsLayout() {
        this.mappingFieldsVisible = true;
        this.openCloseButtonIconName = OPEN_BUTTON_ICON_NAME;
    }

    closeMappingFieldsLayout() {
        this.mappingFieldsVisible = false;
        this.openCloseButtonIconName = CLOSE_BUTTON_ICON_NAME;
    }



}

 class FieldMappingData {

    id;
    sourceObjectField = {
        apiName:'',
        labelName:'',
        type:'',
        required:false,
        referenceTo:''
    }
    targetObjectField = {
        apiName:'',
        labelName:'',
        type:'',
        required:false,
        referenceTo:''
    }

    constructor() {
        this.id = this.generateUUID();
    }

    generateUUID = () => {
        return 'xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx'.replace(/[xy]/g, function (c) {
            var r = (Math.random() * 16) | 0,
                v = c === 'x' ? r : (r & 0x3) | 0x8;
            return v.toString(16);
        });
    };
}