import {api, LightningElement, track} from 'lwc';

export default class ObjectMapping extends LightningElement {

    @track mappingState;
    @track showFilters;
    @track disableAddFiltersButton = true;
    @track showAddFiltersButton = true;
    @track selectedSourceObjectApiName;
    @track selectedTargetObjectApiName;

    @api parentRelatedSourceObjectApiNames = [];
    @api parentRelatedTargetObjectApiNames = [];

    @api parentSourceObjectApiName;
    @api parentTargetObjectApiName;
    @api templateSelectDisable;

    @api isChild = false;

    selectedTemplate;

    @api
    get objectMappingState(){
        return this.mappingState;
    }
    set objectMappingState(mappingStateToSet){
        this.mappingState = new MappingState();
        this.mappingState.load(mappingStateToSet);

        if(this.mappingState && this.mappingState.template && this.mappingState.template.id){
            this.selectedTemplate = mappingStateToSet.template;
            this.selectedSourceObjectApiName = mappingStateToSet.template.sourceObjectApiName;
            this.selectedTargetObjectApiName = mappingStateToSet.template.targetObjectApiName;

            setTimeout(()=>{
                let sourceObjectRelationshipSelector = this.template.querySelector("[data-id='sourceObjectRelationshipSelector']");
                let targetObjectRelationshipSelector = this.template.querySelector("[data-id='targetObjectRelationshipSelector']");
                if(sourceObjectRelationshipSelector && targetObjectRelationshipSelector) {
                    sourceObjectRelationshipSelector.relationshipState = this.mappingState.sourceObjectRelationship;
                    targetObjectRelationshipSelector.relationshipState = this.mappingState.targetObjectRelationship;
                }

            },130);
            setTimeout(()=>{
                let template = this.template.querySelector('c-object-mapping-table');
                template.loadMappingTemplate(this.mappingState.template.id);

            },130)

            if(this.mappingState.filterState){
                this.showAddFiltersButton = false;
                this.showFilters = true;
                setTimeout(()=>{
                    this.template.querySelector('c-object-filter').loadFilterState(this.mappingState.filterState);
                },50);

            }
        }
    }

    @api resetState(){
        this.mappingState = undefined;
        this.showFilters = false;
        this.disableAddFiltersButton = true;
        this.showAddFiltersButton = true;
        this.selectedSourceObjectApiName = undefined;
        this.parentRelatedSourceObjectApiNames = [];
        this.parentRelatedTargetObjectApiNames = [];
        this.templateSelectDisable = false;
        this.selectedTemplate = undefined;

        this.template.querySelector('c-object-mapping-table').resetMappingTemplate();
    }

    handleAddFilterButton(event){
        this.showFilters = true;
        this.showAddFiltersButton = false;

    }

    handleMappingTemplateChange(event){
        this.selectedTemplate = event.detail;
        this.selectedSourceObjectApiName = event.detail.sourceObjectApiName;
        this.selectedTargetObjectApiName = event.detail.targetObjectApiName;
        if(!event.detail.id){
            this.showFilters = false;
            this.disableAddFiltersButton = true;
            this.showAddFiltersButton = true;
        }else{
            this.disableAddFiltersButton = false;

        }

        const objectMappingChangeEvent = new CustomEvent('mappingtempaltechange',{
            detail:this.selectedTemplate
        });
        this.dispatchEvent(objectMappingChangeEvent);
    }

    handleRemoveMappingButton(event){
        const removeMappingEvent = new CustomEvent('removemapping',{
            detail:{id:this.mappingState.externalId}
        });
        this.dispatchEvent(removeMappingEvent);
    }

    @api
    getMappingState(){
        let filterStateComponent = this.template.querySelector('c-object-filter');

        let filterState = null;
        if(filterStateComponent){
            filterState = filterStateComponent.getFilterState();
        }
        this.mappingState.template = this.selectedTemplate;
        this.mappingState.filterState = filterState;

        let sourceObjectRelationshipSelector = this.template.querySelector("[data-id='sourceObjectRelationshipSelector']");
        let targetObjectRelationshipSelector = this.template.querySelector("[data-id='targetObjectRelationshipSelector']");
        if(sourceObjectRelationshipSelector && targetObjectRelationshipSelector){
            this.mappingState.sourceObjectRelationship = sourceObjectRelationshipSelector.relationshipState;
            this.mappingState.targetObjectRelationship = targetObjectRelationshipSelector.relationshipState;
        }
        return this.mappingState;
    }

    @api createEmptyState(){
        let mappingState = new MappingState();
        mappingState.init();
        return mappingState;
    }
}

class MappingState{
    id;
    filterState;
    template;
    externalId;
    sourceObjectRelationship;
    targetObjectRelationship;

    init(){
        this.externalId = this.generateUUID();
    }
    load(mappingStateToLoad){
        if(mappingStateToLoad){
            this.id = mappingStateToLoad.id;
            this.filterState = mappingStateToLoad.filterState;
            this.template = mappingStateToLoad.template;
            this.externalId = mappingStateToLoad.externalId;
            this.sourceObjectRelationship = mappingStateToLoad.sourceObjectRelationship;
            this.targetObjectRelationship = mappingStateToLoad.targetObjectRelationship;
            if(!mappingStateToLoad.externalId){
                this.externalId = this.generateUUID;
            }
        }else{
            this.init();
        }
    }
    generateUUID = () => {
        return 'xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx'.replace(/[xy]/g, function (c) {
            var r = (Math.random() * 16) | 0,
                v = c === 'x' ? r : (r & 0x3) | 0x8;
            return v.toString(16);
        });
    };
}