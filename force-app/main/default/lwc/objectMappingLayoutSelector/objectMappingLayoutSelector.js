import {api, LightningElement, track} from 'lwc';
const LAYOUT_DESCRIPTION_PLACEHOLDER = 'Description';
const LAYOUT_SELECTOR_PLACEHOLDER = 'Select Layout';

export default class ObjectMappingLayoutSelector extends LightningElement {

    labels= {
        layoutDescriptionPlaceholder: LAYOUT_DESCRIPTION_PLACEHOLDER,
        layoutSelectorPlaceholder: LAYOUT_SELECTOR_PLACEHOLDER
    }

    @track selectedObjectMappingLayoutId;
    @track objectMappingLayoutOptions = [];
    @track objectMappingLayoutDescription;

    objectMappingLayoutsCache;

    @api
    get objectMappingLayouts(){
        return this.objectMappingLayoutsCache;
    }
    set objectMappingLayouts(objectLayouts){
        if(objectLayouts && Array.isArray(objectLayouts)){
            this.objectMappingLayoutsCache = objectLayouts;
            this.objectMappingLayoutOptions = objectLayouts.map(layout=>{
                return {
                    label: layout.name,
                    value: layout.id,
                    description: layout.description,
                    isDefault: layout.isDefault
                };
            });
            if(this.objectMappingLayoutOptions.length>0){
               let defaultIndex = this.objectMappingLayoutOptions.findIndex(layout=>layout.isDefault);
               if(defaultIndex > -1){
                   this.loadLayout(this.objectMappingLayoutOptions[defaultIndex].value);
               }else{
                   this.loadLayout(this.objectMappingLayoutOptions[0].value);
               }
            }
        }
    }

    handleObjectMappingLayoutOptionChange(event){
        this.loadLayout(event.detail.value);

    }

    loadLayout(layoutId){
        let selectedLayout = this.objectMappingLayouts.find(layout=>layout.id === layoutId);
        if (selectedLayout) {
            this.objectMappingLayoutDescription = selectedLayout.description;
            this.selectedObjectMappingLayoutId = selectedLayout.id;
            this.dispatchEvent(new CustomEvent('selectedlayoutchange', {detail: {
                id: selectedLayout.id,
                isDefault: selectedLayout.isDefault
           }}));
        }
    }

}