import {api, LightningElement, track, wire} from 'lwc';
import getFieldsBySobjectApiName from '@salesforce/apex/ObjectUtilController.getFieldsBySobjectApiName';
import {reduceErrors, showErrorMessage} from "c/errorHandlingUtils";
const FIELD_SELECTOR_PLACEHOLDER_TEXT = 'Select a field';
export default class ObjectField extends LightningElement {

    labels = {
         fieldSelectorPlaceholderText : FIELD_SELECTOR_PLACEHOLDER_TEXT
    };

    @api fieldOptions =[];
    @api fieldData = {
        apiName:'',
        labelName:'',
        type:'',
        required:false,
        referenceTo:''
    };
    @api disabledActive = false;
    @api disableParentFieldRendering = false;
    @track childFieldData;
    @track fieldsMap;

    @api fieldStyle = '';

    @api
    get childField(){
        return this.childFieldData;
    }
    set childField(fieldData){
        this.childFieldData = fieldData;
        if(this.childFieldData.referenceTo){
            getFieldsBySobjectApiName({sObjectApiName: this.childFieldData.referenceTo,isFormulaIncluded:true})
                .then(data=>{
                    this.fields = data;

                    if(this.childField.parentField){
                        this.fieldData = this.childField.parentField;
                    }
                }).catch(error=>{
                    this.errors = reduceErrors(error);
                    showErrorMessage(this.errors);
            })
        }
    }

    @api
    get fields(){
        return this.fieldsMap.values;
    }
    set fields(fields){
        this.fieldsMap = this.createFieldMap(fields);
        this.fieldOptions = this.createFieldOptions(fields);

    }
    get disabled(){
        if(this.disabledActive){
            return this.fieldData.required;
        }
        return false;
    }

    handleFieldOptionChange(event){
        this.fieldData = this.fieldsMap.get(event.detail.value);
        this.notifyFieldDataChange();
        this.notifyReferenceFieldSelected();
    }
    handleFieldOptionChangeOnChild(event){
        let parentFieldData = event.detail;
        this.fieldData ={
            ...this.fieldData,
            parentField:parentFieldData
        };
       this.notifyFieldDataChange();
    }

    @api validate(){
        let isValid = true;
        let inputFields = this.template.querySelectorAll('.validate');
        inputFields.forEach(inputField =>{
            if(!inputField.checkValidity()) {
                inputField.reportValidity();
                isValid = false;
            }
        });
        return isValid;
    }

    notifyFieldDataChange(){
        const fieldChangeEvent = new CustomEvent('fieldchange',{
            detail:this.fieldData,
            bubbles:true,
        });
        this.dispatchEvent(fieldChangeEvent);
    }
    notifyReferenceFieldSelected(){
        console.log(this.fieldData.referenceTo);
        const referenceFieldSelectedEvent = new CustomEvent('referencefieldselected',{
            detail:this.fieldData.referenceTo != null
        });
        this.dispatchEvent(referenceFieldSelectedEvent);
    }
    createFieldOptions(fields) {
        if(Array.isArray(fields)){
            return fields.map(field=>{
                return {label:field.labelName,value:field.apiName,description:field.apiName}
            });
        }
        return [];
    }
    createFieldMap(fields) {
        let fieldMap = new Map();
        if(Array.isArray(fields)){
            fields.forEach((fieldObj) => {
                fieldMap.set(fieldObj.apiName, fieldObj);
            });
        }
        return fieldMap;
    }

}