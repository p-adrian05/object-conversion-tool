import {api, LightningElement, track} from 'lwc';
const OPEN_BUTTON_ICON_NAME = 'utility:up';
const CLOSE_BUTTON_ICON_NAME = 'utility:down';
export default class ObjectFieldMapping extends LightningElement {

    openCloseButtonIconName = OPEN_BUTTON_ICON_NAME;
    @track parentFieldsVisible = false;
    @track disableParentFieldRendering = false;
    @track referenceFieldSelected = false;

    //deep copy of fieldMappingData attribute to be able to modify it
    @track fieldMappingDataCopy;

    @api sourceObjectFields;
    @api targetObjectFields;

    targetObjectFieldStyle  ='width:19rem';
    @api
    get fieldMappingData(){
        return this.fieldMappingDataCopy;
    }
    set fieldMappingData(data){
        this.fieldMappingDataCopy = Object.assign({},data);
        this.handleParentFieldMappingVisibility(this.fieldMappingDataCopy.sourceObjectField.referenceTo);
    }


    @api validate(){
        let isValid = true;
        let inputFields = this.template.querySelectorAll('c-object-field');
        inputFields.forEach(inputField =>{
            if(!inputField.validate()) {
                isValid = false;
            }
        });
        return isValid;
    }

    handleSourceObjectFieldChange(event){
        this.fieldMappingDataCopy.sourceObjectField = event.detail;
        this.notifyMappingDataChange();
    }
    handleTargetObjectFieldChange(event){
        this.fieldMappingDataCopy.targetObjectField = event.detail;
        this.notifyMappingDataChange();
    }
    handleDeleteFieldMappingData(event){
        const fieldMappingDataDeleteEvent = new CustomEvent('fieldmappingdatadelete', {
            detail:{
                fieldMappingDataId:this.fieldMappingData.id
            }
        })
        this.dispatchEvent(fieldMappingDataDeleteEvent);
    }

    notifyMappingDataChange(){
        const fieldMappingDataChangeEvent = new CustomEvent('fieldmappingdatachange', {
            detail:{
                fieldMappingData:this.fieldMappingData
            }
        })
        this.dispatchEvent(fieldMappingDataChangeEvent);
    }
    handleReferenceFieldSelected(event){
       this.handleParentFieldMappingVisibility(event.detail);
    }
    handleParentFieldMappingVisibility(boolValue){
        if(boolValue){
            this.targetObjectFieldStyle = 'width:16.25rem';
            this.referenceFieldSelected = true;
            this.openParentFieldMappings();
        }else{
            this.targetObjectFieldStyle = 'width:19rem';
            this.referenceFieldSelected = false;
            this.disableParentFieldRendering = true;
            this.closeParentFieldMappings();
        }
    }

    handleCloseParentMappingButtonClicked(event){
        if (!this.parentFieldsVisible) {
            this.openParentFieldMappings();
        } else {
            this.closeParentFieldMappings();
        }
    }
    openParentFieldMappings() {
        this.parentFieldsVisible = true;
        this.disableParentFieldRendering = false;
        this.openCloseButtonIconName = OPEN_BUTTON_ICON_NAME;
    }

    closeParentFieldMappings() {
        this.parentFieldsVisible = false;
        this.disableParentFieldRendering = true;
        this.openCloseButtonIconName = CLOSE_BUTTON_ICON_NAME;
    }
}