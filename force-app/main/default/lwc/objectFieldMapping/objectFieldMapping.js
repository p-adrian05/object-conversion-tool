

import {api, LightningElement, track} from 'lwc';

export default class ObjectFieldMapping extends LightningElement {

    //deep copy of fieldMappingData attribute to be able to modify it
    @track fieldMappingDataCopy;

    @api sourceObjectFields;
    @api targetObjectFields;


    @api
    get fieldMappingData(){
        return this.fieldMappingDataCopy;
    }
    set fieldMappingData(data){
        this.fieldMappingDataCopy = Object.assign({},data);
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

}