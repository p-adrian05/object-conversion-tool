import {api, LightningElement, track, wire} from 'lwc';
import getChildRelationships from '@salesforce/apex/ObjectUtilController.getObjectRelationships';
import {reduceErrors, showErrorMessage} from "c/errorHandlingUtils";
const RELATIONSHIP_SELECTOR_PLACEHOLDER_TEXT = 'Select a relationship';
export default class ObjectChildRelationshipSelector extends LightningElement {
    labels = {
        relationshipSelectorPlaceholderText: RELATIONSHIP_SELECTOR_PLACEHOLDER_TEXT
    };

    @api fieldStyle;
    @api parentObjectApiName;
    @api childObjectApiName;
    @api sourceObjectSelector = false;
    @api selectedChildRelationshipName;
    @api selectedChildRelationshipFieldApiName;
    @track childRelationshipOptions = [];

    @wire(getChildRelationships, {parentObjectApiName: '$parentObjectApiName', childObjectApiName: '$childObjectApiName'})
    wiredChildRelationships({error, data}){
        if(data){
            this.childRelationshipOptions = data.map((childRelationship) => {
                return {label: childRelationship.fieldApiName,
                        value: childRelationship.fieldApiName,
                        description: childRelationship.relationshipName
            }});
            if(this.parentObjectApiName === this.childObjectApiName && this.sourceObjectSelector){
                this.childRelationshipOptions.push({label: 'Id', value: 'Id', description: this.parentObjectApiName});
            }
            if(this.childRelationshipOptions.length === 1){
                this.selectedChildRelationshipFieldApiName = this.childRelationshipOptions[0].value;
            }
        }
        else if(error){
            this.childRelationshipOptions = undefined;
            this.errors = reduceErrors(error);
            showErrorMessage(this.errors);
        }
    }

    handleChildRelationshipChange(event){
        this.selectedChildRelationshipName = event.detail.description;
        this.selectedChildRelationshipFieldApiName = event.detail.value;
    }

    @api get relationshipState() {
        let indexToGet = this.childRelationshipOptions.findIndex((childRelationship) => {
            return childRelationship.value === this.selectedChildRelationshipFieldApiName;
        });
        if (indexToGet !== -1) {
            let selectedChildRelationOption = this.childRelationshipOptions.at(indexToGet);
            return new ObjectRelationship(selectedChildRelationOption.description, selectedChildRelationOption.value);
        }else {
            return new ObjectRelationship(null, null);
        }
    }
    set relationshipState(objectRelationship) {
        if (objectRelationship) {
            this.selectedChildRelationshipFieldApiName = objectRelationship.fieldApiName;
        }
    }
}

class ObjectRelationship {
    relationshipName;
    fieldApiName;

    constructor(relationshipName, fieldApiName) {
        this.relationshipName = relationshipName;
        this.fieldApiName = fieldApiName;
    }
}