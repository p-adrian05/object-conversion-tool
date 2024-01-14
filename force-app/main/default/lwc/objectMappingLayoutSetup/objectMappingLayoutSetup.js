import {api, LightningElement, track, wire} from 'lwc';
import getMappingLayouts from '@salesforce/apex/ObjectMappingLayoutController.getMappingLayouts';
import upsertMappingLayout from '@salesforce/apex/ObjectMappingLayoutController.upsertMappingLayout';
import deleteMappingLayout from '@salesforce/apex/ObjectMappingLayoutController.deleteMappingLayout';
import {reduceErrors, showErrorMessage, showSuccessMessage,showWarningMessage} from 'c/errorHandlingUtils';
import {refreshApex} from "@salesforce/apex";
import ObjectMappingDeleteModal from "c/objectMappingDeleteModal";

const LAYOUT_SAVED_SUCCESS_MESSAGE = 'Layout successfully saved!';
const SAVE_WITHOUT_NAME_WARNING_MESSAGE= 'Please add a Layout name!';
const SAVE_WITHOUT_MAPPING_WARNING_MESSAGE= 'Please add at least one template!';
const DELETE_LAYOUT_MODAL_MESSAGE= 'Are you sure you want to delete?';

const LAYOUT_SELECTOR_PLACEHOLDER = "Select Layout";
const LAYOUT_NAME_INPUT_PLACEHOLDER = "Add a name to your layout";
const LAYOUT_DESCRIPTION_INPUT_PLACEHOLDER = "Description";
const LAYOUT_SAVE_BUTTON_LABEL = "Save";
const LAYOUT_RELOAD_BUTTON_LABEL = "Reload";
const LAYOUT_DELETE_BUTTON_LABEL = "Delete";
const LAYOUT_CREATE_NEW_BUTTON_LABEL = "Create New";
export default class ObjectMappingLayoutSetup extends LightningElement {

    labels= {
        layoutSelectorPlaceholder: LAYOUT_SELECTOR_PLACEHOLDER,
        layoutNameInputPlaceholder: LAYOUT_NAME_INPUT_PLACEHOLDER,
        layoutDescriptionInputPlaceholder: LAYOUT_DESCRIPTION_INPUT_PLACEHOLDER,
        layoutSaveButtonLabel: LAYOUT_SAVE_BUTTON_LABEL,
        layoutReloadButtonLabel: LAYOUT_RELOAD_BUTTON_LABEL,
        layoutDeleteButtonLabel: LAYOUT_DELETE_BUTTON_LABEL,
        layoutCreateNewButtonLabel: LAYOUT_CREATE_NEW_BUTTON_LABEL
    }

    @track selectedMappingLayoutOption;
    @track mappingLayoutOptions = [];
    @track mappingLayoutName;

    @track selectedMappingLayoutId;
    @track mappingLayoutDescription;

    @track isLoading;

    mappingLayoutsResponse;


    @wire(getMappingLayouts)
    getLayoutRecords(mappingLayoutsResponse){
        if(mappingLayoutsResponse.data){
             this.mappingLayoutsResponse = mappingLayoutsResponse;
             this.mappingLayoutOptions = mappingLayoutsResponse.data.map(layout=>{
                 return {
                     label:layout.name,
                     value:layout.id,
                     description:layout.description,
                     isDefault: layout.isDefault
                 }
             });
        }else if(mappingLayoutsResponse.error){
            this.mappingLayoutOptions = undefined;
            this.error = reduceErrors(mappingLayoutsResponse.error);
            showErrorMessage(this.error);
            console.error(JSON.stringify(this.error));
        }
    }

    validateSetup(){
        if (!this.mappingLayoutName || this.mappingLayoutName.trim().length === 0) {
            showWarningMessage(SAVE_WITHOUT_NAME_WARNING_MESSAGE);
            return false;
        }
        if(!this.template.querySelector('c-object-mapping-layout').selectedParentMappingTemplate){
            showWarningMessage(SAVE_WITHOUT_MAPPING_WARNING_MESSAGE);
            return false;
        }
        return true;
    }

    handleSaveButtonClick(event){
        this.upsertLayout();
    }

    upsertLayout(){
        if(this.validateSetup()){
            const layoutComponent = this.template.querySelector("c-object-mapping-layout");
            this.handleLoading();

            let isDefault = false;
            if(this.selectedMappingLayoutOption){
                isDefault = this.selectedMappingLayoutOption.isDefault;
            }
            let layoutObject = {
                id:this.selectedMappingLayoutId,
                name:this.mappingLayoutName,
                isDefault:isDefault,
                description:this.mappingLayoutDescription
            };

            try{
                layoutObject = { ...layoutObject,
                    parentMapping:layoutComponent.getParentMappingState(),
                    childMappings:layoutComponent.getChildMappingStates()
                };
                console.log('UPSERT LAYOUT:');
                console.log(JSON.stringify(layoutObject));

                upsertMappingLayout({
                    objectMappingLayoutJSON:JSON.stringify(layoutObject)})
                    .then(upsertLayoutResponse=>{
                        if(this.selectedMappingLayoutId){
                            this.mappingLayoutOptions
                                .filter(layoutOption => layoutOption.value === this.selectedMappingLayoutId)
                                .forEach(layoutOption=>{
                                    layoutOption.label = this.mappingLayoutName;
                                    layoutOption.description = this.mappingLayoutDescription;
                                });
                        }else {
                            this.mappingLayoutOptions.push({
                                label:this.mappingLayoutName,
                                value:upsertLayoutResponse.layoutId,
                                description:this.mappingLayoutDescription
                            });
                        }
                        this.mappingLayoutOptions = [...this.mappingLayoutOptions];
                        this.loadMappingLayout(upsertLayoutResponse.layoutId);

                        layoutComponent.refreshCachedData(upsertLayoutResponse.layoutId);
                        showSuccessMessage(LAYOUT_SAVED_SUCCESS_MESSAGE);
                    }).catch(error=>{
                    this.error = reduceErrors(error);
                    showErrorMessage(this.error);
                    console.error(JSON.stringify(this.error));
                }).finally(()=>{
                    this.handleDoneLoading();
                })
            }catch (e) {
                this.error = reduceErrors(e);
                showErrorMessage(this.error);
                console.error(JSON.stringify(this.error));
                this.handleDoneLoading();
            }
        }
    }
    handleMappingLayoutOptionChange(event){
        this.loadMappingLayout(event.detail.value);
    }
    handleMappingLayoutNameInputChange(event){
        this.mappingLayoutName = event.detail.value;
    }
    handleMappingLayoutDescriptionChange(event){
        this.mappingLayoutDescription = event.detail.value;
    }
    @api loadMappingLayout(mappingLayoutId){
        this.selectedMappingLayoutOption = this.mappingLayoutOptions.find(opt=>opt.value === mappingLayoutId);
        if(this.selectedMappingLayoutOption){
            this.mappingLayoutName = this.selectedMappingLayoutOption.label;
            this.mappingLayoutDescription = this.selectedMappingLayoutOption.description;
            this.selectedMappingLayoutId = mappingLayoutId;
        }
    }

    handleResetButtonClick(event){
        this.resetLayout();
    }
    async handleDeleteButtonClick(event){
        if(this.selectedMappingLayoutId){
            const result = await ObjectMappingDeleteModal.open({
                size: 'small',
                description: 'Delete layout',
                content: DELETE_LAYOUT_MODAL_MESSAGE,
            });
            if(result ==='ok'){
                this.deleteLayout(this.selectedMappingLayoutId);
            }
        }
    }

    deleteLayout(layoutId){
        if(layoutId){
            this.handleLoading();
            deleteMappingLayout({layoutId: layoutId})
                .then(result=>{
                    this.resetLayout();
                    showSuccessMessage(result);

                    return refreshApex(this.mappingLayoutsResponse);

                }).catch(error=>{
                    this.error = reduceErrors(error);
                    showErrorMessage(this.error);
                    console.error(JSON.stringify(this.error));
            }).finally(()=>{
                this.handleDoneLoading();
            })
        }
    }
    handleRestoreButtonClick(event){
        const selectedMappingLayoutIdOriginal = this.selectedMappingLayoutId;
        this.resetLayout();
        this.loadMappingLayout(selectedMappingLayoutIdOriginal);
        this.template.querySelector('c-object-mapping-layout').refreshCachedData(selectedMappingLayoutIdOriginal);
    }
    @api resetLayout(){
        this.selectedMappingLayoutId = undefined;
        this.selectedMappingLayoutOption = undefined;
        this.mappingLayoutName = undefined;
        this.mappingLayoutDescription = undefined;
        this.template.querySelector('c-object-mapping-layout').resetLayout();
    }
    handleLoading() {
        this.isLoading = true;
    }

    // Handles done loading event
    handleDoneLoading() {
        this.isLoading = false;
    }
}