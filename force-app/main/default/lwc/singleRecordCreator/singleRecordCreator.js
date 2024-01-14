import {api, LightningElement, track, wire} from 'lwc';
import getMappingLayoutsBySourceRecordId from '@salesforce/apex/ObjectMappingLayoutController.getObjectMappingLayoutsBySourceRecordId';
import getCurrentUserInfo from '@salesforce/apex/ObjectUtilController.getCurrentUserInfo';
import {showErrorMessage,reduceErrors,showSuccessMessage} from 'c/errorHandlingUtils';
import convertObjectFromLayout from '@salesforce/apex/ObjectMappingConverterController.convertObjectFromLayout';
import markDefaultLayout from '@salesforce/apex/ObjectMappingLayoutController.markDefaultLayout';
import {NavigationMixin} from "lightning/navigation";
import {refreshApex} from "@salesforce/apex";
const MARK_DEFAULT_BUTTON_LABEL = 'Mark as Default';
const DEFAULT_SELECTED_BUTTON_LABEL = 'Default Selected';
const CONVERT_BUTTON_LABEL = 'Convert';
const VIEW_CREATED_RECORD_BUTTON_LABEL = 'View Created Record';
export default class SingleRecordCreator extends NavigationMixin(LightningElement) {

    labels = {
        markDefaultButtonLabel: MARK_DEFAULT_BUTTON_LABEL,
        defaultSelectedButtonLabel: DEFAULT_SELECTED_BUTTON_LABEL,
        convertButtonLabel: CONVERT_BUTTON_LABEL,
        viewCreatedRecordButtonLabel: VIEW_CREATED_RECORD_BUTTON_LABEL
    }

    @api sourceRecordId;
    @track createdTargetRecordId;
    @track selectedObjectMappingLayoutId;
    @track selectedObjectMappingLayoutIsDefault;
    @track objectMappingLayouts = [];
    objectMappingLayoutsResponseCache;
    @track isLoading;
    @track isCurrentUserAdmin = false;

    @wire (getMappingLayoutsBySourceRecordId, {sourceRecordId: '$sourceRecordId'})
    getMappingLayouts(response){
        if(response.data){
            this.objectMappingLayoutsResponseCache =response;
            this.objectMappingLayouts = response.data;
        }else if (response.error){
            this.error = reduceErrors(response.error);
            showErrorMessage(this.error);
            console.error(JSON.stringify(this.error));
        }
    }
    @wire (getCurrentUserInfo)
    getCurrentUser(response){
        if(response.data){
           this.isCurrentUserAdmin = response.data.isAdmin;
        }else if (response.error){
            this.error = reduceErrors(response.error);
            showErrorMessage(this.error);
            console.error(JSON.stringify(this.error));
        }
    }
    handleMappingLayoutChange(event){
        this.selectedObjectMappingLayoutId = event.detail.id;
        this.selectedObjectMappingLayoutIsDefault = event.detail.isDefault;
    }

    handleDefaultButtonClick(event){
        if(this.selectedObjectMappingLayoutId){
            this.isLoading = true;
            markDefaultLayout({objectMappingLayoutId: this.selectedObjectMappingLayoutId})
                .then(result => {
                    refreshApex(this.objectMappingLayoutsResponseCache);
                    showSuccessMessage(result);
                })
                .catch(error=>{
                    this.error = reduceErrors(error);
                    showErrorMessage(this.error);
                    console.error(JSON.stringify(this.error));
                }).finally(()=> {
                this.isLoading = false;
            });
        }
     }
    handleConvertButtonClick(event){
        if(this.selectedObjectMappingLayoutId){
            this.isLoading = true;
            convertObjectFromLayout({sourceRecordId: this.sourceRecordId,
                objectMappingLayoutId: this.selectedObjectMappingLayoutId})
                .then(result=>{
                    if(result){
                        this.createdTargetRecordId = result;
                        showSuccessMessage('Record created successfully with Id: '+result);
                    }else{
                        showErrorMessage('No record created!');
                    }
                })
                .catch(error=>{
                    this.error = reduceErrors(error);
                    showErrorMessage(this.error);
                    console.error(JSON.stringify(this.error));
                }).finally(()=>{
                this.isLoading = false;
            });
        }
    }
    handleViewCreatedRecordButtonClick(event){
        if(this.createdTargetRecordId){
            this.openRecordViewPage(this.createdTargetRecordId);
        }
    }

    openRecordViewPage(recordId) {
        if(recordId) {
            this[NavigationMixin.GenerateUrl]({
                type: "standard__recordPage",
                attributes: {
                    recordId: recordId,
                    actionName: 'view'
                }
            }).then(url => {
                window.open(url, "_blank");
            });
        }
    }
}