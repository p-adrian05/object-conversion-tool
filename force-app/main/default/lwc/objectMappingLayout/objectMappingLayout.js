import {api, LightningElement, track, wire} from 'lwc';
import getChildObjectApiNamesByParentObjectApiName from '@salesforce/apex/ObjectUtilController.getChildObjectApiNamesByParentObjectApiName';
import {reduceErrors, showErrorMessage, showSuccessMessage} from 'c/errorHandlingUtils';
import getMappingLayout from '@salesforce/apex/ObjectMappingLayoutController.getMappingLayout';
import {refreshApex} from "@salesforce/apex";
const ADD_CHILD_MAPPING_BUTTON_LABEL = 'Add child template';
export default class ObjectMappingLayout extends LightningElement {

    labels = {
        addChildMappingButtonLabel: ADD_CHILD_MAPPING_BUTTON_LABEL
    }

    @track childMappings = [];
    childMappingStatesCache = [];
    @track parentMappingState;
    isLoading;

    @api selectedParentMappingTemplate;
    @track selectedParentSourceObjectApiName;
    @track selectedParentTargetObjectApiName;
    @track parentRelatedSourceObjectApiNames = [];
    @track parentRelatedTargetObjectApiNames = [];

    @track disableAddChildButton = true;
    @track parentTemplateSelectDisable = false;

    @api layoutRecordId;

    @track horizontalAlign = 'center';

    layoutRecordResponse;

    @api get childMappingStates(){
        return this.childMappings;
    }
    set childMappingStates(childMappings){
        if(Array.isArray(childMappings)){
            this.childMappings = childMappings;

            if(this.childMappings.length>2){
                this.horizontalAlign = 'start';
            }
            else{
                this.horizontalAlign = 'center';
            }
        }

    }

    @wire(getMappingLayout, { recordId: '$layoutRecordId'})
    wiredLayoutRecord(response) {
        if(response.data){
            this.layoutRecordResponse = response;
            const layoutObj = response.data;
            this.parentMappingState = layoutObj.parentMapping;
            this.childMappingStatesCache = [...layoutObj.childMappings];
            this.parentTemplateSelectDisable = true;
        }else if(response.error){
            this.error = reduceErrors(response.error);
            showErrorMessage(this.error);
            console.error(JSON.stringify(this.error));
        }
    }
    @api
    refreshCachedData(recordId) {
        this.layoutRecordId = recordId;
        refreshApex(this.layoutRecordResponse);
    }

    @api resetLayout(){
        this.childMappingStates = [];
        this.childMappingStatesCache = [];
        this.parentMappingState = undefined;
        this.selectedParentMappingTemplate = undefined;
        this.selectedParentSourceObjectApiName = undefined;
        this.selectedParentTargetObjectApiName = undefined;
        this.parentRelatedSourceObjectApiNames = [];
        this.parentRelatedTargetObjectApiNames = [];
        this.disableAddChildButton = true;
        this.parentTemplateSelectDisable = false;
        this.layoutRecordId = undefined;
        this.template.querySelector("[data-id='parentMapping']").resetState();
    }
    handleAddChildButtonClicked(event) {
        this.childMappingStates.unshift(this.template.querySelector('c-object-mapping').createEmptyState());
        this.childMappingStates = [...this.childMappingStates];
        this.parentTemplateSelectDisable = true;
    }


    handleParentMappingChange(event){
        this.selectedParentMappingTemplate = event.detail;
        this.selectedParentSourceObjectApiName = event.detail.sourceObjectApiName;
        this.selectedParentTargetObjectApiName = event.detail.targetObjectApiName;

        this.disableAddChildButton = this.isAddChildButtonDisabled();
        if(!this.selectedParentMappingTemplate.id){
            this.childMappingStates = [];
        }else{
            this.isLoading = true;
            this.getChildSObjects(this.selectedParentMappingTemplate.sourceObjectApiName,
                (apiNames=>{
                    this.parentRelatedSourceObjectApiNames = apiNames;
                    let selectedConvertFromObjectApiName = this.selectedParentMappingTemplate.sourceObjectApiName;
                    if(!this.parentRelatedSourceObjectApiNames.includes(selectedConvertFromObjectApiName)){
                        this.parentRelatedSourceObjectApiNames.push(selectedConvertFromObjectApiName);
                    }
                    this.getChildSObjects(this.selectedParentMappingTemplate.targetObjectApiName,
                        (apiNames=>{
                            this.parentRelatedTargetObjectApiNames = apiNames;
                            this.childMappingStates = this.childMappingStatesCache;
                            this.isLoading = false;
                        }));
                }));

        }
    }
    handleRemoveChildMapping(event){
        let indexToDelete = this.childMappingStates.findIndex(mappingState=>mappingState.externalId.toString()===event.detail.id.toString());
        if(indexToDelete!==-1){
            this.childMappingStates.splice(indexToDelete,1);
        }
        if(this.childMappingStates.length===0 && !this.layoutRecordId){
            this.parentTemplateSelectDisable = false;
        }
        this.childMappingStates = [...this.childMappingStates];
    }

    getChildSObjects(sObjectApiName,successCallback){
        if(sObjectApiName){
            getChildObjectApiNamesByParentObjectApiName({parentSObjectApiName:sObjectApiName})
                .then(result=>{
                    successCallback(result.map(objectResult=>{return objectResult.objectApiName}));
                }).catch(error=>{
                this.error = reduceErrors(error);
                showErrorMessage(this.error);
                console.error(JSON.stringify(this.error));
            });
        }
    }

    @api
    getParentMappingState(){
        return this.template.querySelector("[data-id='parentMapping']").getMappingState();
    }
    @api
    getChildMappingStates(){
        let childMappingComponents = this.template.querySelectorAll('.childMapping');
        let childMappings = [];
        childMappingComponents
            .forEach(childMappingComponent=>{
                childMappings.push(childMappingComponent.getMappingState());
            });
        return childMappings;
    }
    isAddChildButtonDisabled(){
        return !(this.selectedParentMappingTemplate && this.selectedParentMappingTemplate.id);
    }
}