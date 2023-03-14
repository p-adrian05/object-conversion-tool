
import {api, LightningElement, track, wire} from 'lwc';
import getMappingLayoutsBySourceRecordId from '@salesforce/apex/ObjectMappingLayoutController.getObjectMappingLayoutsBySourceRecordId';
import {showErrorMessage,reduceErrors,showSuccessMessage} from 'c/errorHandlingUtils';
import convertObject from '@salesforce/apex/ObjectMappingLayoutController.convertObject';
import markDefaultLayout from '@salesforce/apex/ObjectMappingLayoutController.markDefaultLayout';
import {NavigationMixin} from "lightning/navigation";
import {refreshApex} from "@salesforce/apex";
export default class SingleRecordCreator extends NavigationMixin(LightningElement) {

    @api sourceRecordId = '0066800000CAePCAA1';
    @track createdTargetRecordId;
    @track selectedObjectMappingLayoutId;
    @track selectedObjectMappingLayoutIsDefault;
    @track objectMappingLayouts = [];
    objectMappingLayoutsResponseCache;
    @track isLoading;

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
            convertObject({sourceRecordId: this.sourceRecordId,
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