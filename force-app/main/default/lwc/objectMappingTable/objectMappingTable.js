import {api, LightningElement, track, wire} from 'lwc';
import getMappingTemplatesByObjectApiNames from '@salesforce/apex/ObjectMappingTemplateController.getMappingTemplatesByObjectApiNames';
import upsertMappingTemplate from '@salesforce/apex/ObjectMappingTemplateController.upsertMappingTemplate';
import deleteMappingTemplate from '@salesforce/apex/ObjectMappingTemplateController.deleteMappingTemplate';
import {reduceErrors, showErrorMessage, showSuccessMessage, showWarningMessage} from 'c/errorHandlingUtils';
import ObjectMappingDeleteModal from "c/objectMappingDeleteModal";
import {refreshApex} from "@salesforce/apex";
const TEMPLATE_SAVED_SUCCESS_MESSAGE = 'Object Mapping Template successfully saved!';
const DELETE_TEMPLATE_MODAL_MESSAGE = 'Are you sure you want to delete?';
const TEMPLATE_SELECTOR_PLACEHOLDER = "Select Template";
const TEMPLATE_NAME_INPUT_PLACEHOLDER = "Add a name to your template";
const TEMPLATE_SAVE_BUTTON_LABEL = "Save";
const TEMPLATE_RELOAD_BUTTON_LABEL = "Reload";
const TEMPLATE_DELETE_BUTTON_LABEL = "Delete";
const TEMPLATE_CREATE_NEW_BUTTON_LABEL = "Create New";
export default class ObjectMappingTable extends LightningElement {

    labels = {
        templateSelectorPlaceholder: TEMPLATE_SELECTOR_PLACEHOLDER,
        templateNameInputPlaceholder: TEMPLATE_NAME_INPUT_PLACEHOLDER,
        templateSaveButtonLabel: TEMPLATE_SAVE_BUTTON_LABEL,
        templateReloadButtonLabel: TEMPLATE_RELOAD_BUTTON_LABEL,
        templateDeleteButtonLabel: TEMPLATE_DELETE_BUTTON_LABEL,
        templateCreateNewButtonLabel: TEMPLATE_CREATE_NEW_BUTTON_LABEL
    }

    @api title;
    @api targetObjectApiNames = [];
    @api sourceObjectApiNames = [];

    //objectMappingTemplate related attributes
    @track selectedMappingTemplateId;
    @track selectedMappingTemplateName;
    @track mappingTemplateOptions = [];
    @track selectedMappingTemplateOption;

    @track error;
    @track isLoading;

    @api templateSelectDisable = false;
    @api readOnly = false;
    @api hideFieldMappings = false;
    templateSelectWasDisabled = false;

    templatesResponse;


    @wire(getMappingTemplatesByObjectApiNames,{
        sourceObjectApiNames : '$sourceObjectApiNames',
        targetObjectApiNames:'$targetObjectApiNames'})
    mappingTemplates(response){
        if(response.data){
            this.templatesResponse = response;
            this.mappingTemplateOptions = response.data.map(mappingTemplate=>{
                return {label:mappingTemplate.name,
                        value:mappingTemplate.id,
                        sourceObjectApiName:mappingTemplate.sourceObjectApiName,
                        targetObjectApiName:mappingTemplate.targetObjectApiName}
            });
        }else if(response.error){
            this.mappingTemplateOptions = undefined;
            this.error = reduceErrors(response.error);
            showErrorMessage(this.error);
            console.error(JSON.stringify(this.error));
        }
        this.handleDoneLoading();
    }

    connectedCallback() {
        this.templateSelectWasDisabled = this.templateSelectDisable;
        this.templateSelectDisable = false;
        this.handleLoading();
    }

    handleMappingTemplateOptionChange(event) {
        this.loadMappingTemplate(event.detail.value);
    }

    @api loadMappingTemplate(templateId){
        this.selectedMappingTemplateId = templateId;
        this.handleLoading();
        setTimeout(()=>{
            this.template.querySelector('c-object-mapping-form').loadTemplate(templateId);
            if(this.templateSelectWasDisabled){
                this.templateSelectDisable = true;
            }
        },200);

        if(this.mappingTemplateOptions.length===0){
            return refreshApex(this.templatesResponse);
        }

    }
    handleMappingTemplateNameInputChange(event){
        if (event.detail.value.trim().length === 0) {
            this.resetMappingTemplate();
        } else {
            this.selectedMappingTemplateName = event.detail.value;
        }
    }

    @api resetMappingTemplate(){
        this.selectedMappingTemplateName = undefined;
        this.selectedMappingTemplateOption = undefined;
        this.selectedMappingTemplateId = undefined;

        this.template.querySelector('c-object-mapping-form').removeTemplate();
        this.notifySelectedTemplateRecordChange();
    }
    // Handles loading event
    handleLoading() {
        this.isLoading = true;
    }

    // Handles done loading event
    handleDoneLoading() {
        this.isLoading = false;
    }

    handleSaveButtonClick(event) {
        if(this.validateForm()){
            this.upsertTemplate();
       }
    }
    handleResetButtonClick(event){
        this.resetMappingTemplate();
    }
    handleRestoreButtonClick(event){
        this.template.querySelector('c-object-mapping-form').restoreFieldMappings();
    }
    async handleDeleteModalClick(event) {
        if(this.selectedMappingTemplateId){
            const result = await ObjectMappingDeleteModal.open({
                size: 'small',
                description: 'Delete template',
                content: DELETE_TEMPLATE_MODAL_MESSAGE,
            });
            if(result ==='ok'){
                this.deleteTemplate();
            }
        }
    }

    deleteTemplate(){
        if(this.selectedMappingTemplateId){
            this.handleLoading();
            deleteMappingTemplate({mappingTemplateId: this.selectedMappingTemplateId})
                .then(result=>{
                    this.resetMappingTemplate();
                    this.notifySelectedTemplateRecordChange();

                    showSuccessMessage(result);
                    return refreshApex(this.templatesResponse);

                }).catch(error=>{
                    this.error = reduceErrors(error);
                    showErrorMessage(this.error);
                    console.error(JSON.stringify(this.error));
            }).finally(()=>{
                this.handleDoneLoading();
            })
        }

    }
    upsertTemplate(){
            this.handleLoading();
            try{
                let mappingFormComponent = this.template.querySelector('c-object-mapping-form');
                let fieldMappings = mappingFormComponent.getFieldMappings();
                if(!fieldMappings || fieldMappings.length===0){
                    throw new Error ('No field mappings found.Please add field mappings to save the template.');
                }

                let mappingTemplateObject = {
                    id: this.selectedMappingTemplateId,
                    sourceObjectApiName: mappingFormComponent.selectedSourceObjectApiName,
                    targetObjectApiName: mappingFormComponent.selectedTargetObjectApiName,
                    name: this.selectedMappingTemplateName,
                    description: mappingFormComponent.mappingTemplateDescription,
                    fieldMappings: fieldMappings
                };
                console.log('UPSERT TEMPLATE:');
                console.log(JSON.stringify(mappingTemplateObject));

                upsertMappingTemplate({
                    mappingTemplateJSON: JSON.stringify(mappingTemplateObject)
                })
                    .then(response => {

                        if(this.selectedMappingTemplateId){
                            this.mappingTemplateOptions
                                .filter(templateOption => templateOption.value === this.selectedMappingTemplateId)
                                .forEach(templateOption=>{
                                    templateOption.label = this.selectedMappingTemplateName;
                                });
                        }else{
                            this.selectedMappingTemplateOption = {
                                label:this.selectedMappingTemplateName,
                                value:response.templateId,
                                sourceObjectApiName:mappingFormComponent.selectedSourceObjectApiName,
                                targetObjectApiName: mappingFormComponent.selectedTargetObjectApiName
                            }
                            this.mappingTemplateOptions.push(this.selectedMappingTemplateOption);
                        }
                        this.mappingTemplateOptions = [...this.mappingTemplateOptions];
                        this.selectedMappingTemplateId = response.templateId;

                        showSuccessMessage(TEMPLATE_SAVED_SUCCESS_MESSAGE);
                        mappingFormComponent.refreshCachedData(response.templateId);
                        this.notifySelectedTemplateRecordChange();

                        if(this.templateSelectWasDisabled){
                            this.templateSelectDisable = true;
                        }

                        return refreshApex(this.templatesResponse);

                    }).catch(error => {
                    this.error = reduceErrors(error);
                    showErrorMessage(this.error);
                    console.error(JSON.stringify(this.error));
                }).finally(()=>{
                    this.handleDoneLoading();
                })
            }catch(error){
                this.error = reduceErrors(error);
                showErrorMessage(this.error);
                console.error(JSON.stringify(this.error));
                this.handleDoneLoading();
            }

    }

    notifySelectedTemplateRecordChange(){
        const templateRecordChangeEvent = new CustomEvent('mappingtemplatechange',{
            detail:new Template(this.selectedMappingTemplateOption)
        });
        this.dispatchEvent(templateRecordChangeEvent);
    }
    handleTemplateLoaded(event){
        this.selectedMappingTemplateOption = this.mappingTemplateOptions.find(opt => opt.value === event.detail);
        this.selectedMappingTemplateName =  this.selectedMappingTemplateOption.label;
        this.selectedMappingTemplateId =  this.selectedMappingTemplateOption.value;
        this.handleDoneLoading();
        this.notifySelectedTemplateRecordChange();
    }

    validateForm(){
        let isValid = this.template.querySelector('c-object-mapping-form').validate();

        if(!this.selectedMappingTemplateName){
            showErrorMessage('ObjectMappingTemplate name cannot be empty!');
            isValid = false;
        }
        return isValid;
    }

}
class Template {
    id;
    sourceObjectApiName;
    targetObjectApiName;

    constructor(selectedMappingTemplateOption) {
        if(selectedMappingTemplateOption){
            this.id = selectedMappingTemplateOption.value;
            this.sourceObjectApiName = selectedMappingTemplateOption.sourceObjectApiName;
            this.targetObjectApiName = selectedMappingTemplateOption.targetObjectApiName;
        }
    }
}