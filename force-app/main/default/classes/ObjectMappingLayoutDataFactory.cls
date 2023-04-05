@IsTest
public with sharing class ObjectMappingLayoutDataFactory {

    public static Object_Mapping_Layout__c createObjectMappingLayout(String name,Boolean doInsert){
        Object_Mapping_Layout__c layout = new Object_Mapping_Layout__c(
                Name = name,
                IsDefault__c = false,
                Description__c = 'Test layout'
        );
        if(doInsert){
            insert layout;
        }
        return layout;
    }
    public static List<Object_Mapping_Layout__c> createObjectMappingLayouts(Integer count,Boolean doInsert){
        List<Object_Mapping_Layout__c> layouts = new List<Object_Mapping_Layout__c>();
        for(Integer i=0;i<count;i++){
            layouts.add(createObjectMappingLayout('Test layout'+i,false));
        }
        if(doInsert){
            insert layouts;
        }
        return layouts;
    }

    public static Object_Mapping__c createObjectMapping(Id mappingTemplateLayoutId,Id mappingTemplateId,Boolean doInsert){
        Object_Mapping__c objectMapping = new Object_Mapping__c(
                Object_Mapping_Template__c =mappingTemplateId,
                Object_Mapping_Layout__c = mappingTemplateLayoutId,
                External_Id__c = 'External_Id__c'+mappingTemplateId
        );
        if(doInsert){
            insert objectMapping;
        }
        return objectMapping;
    }
    public static ObjectMappingLayout createObjectMappingLayoutModel(){
        ObjectMappingLayout objectMappingLayoutModel = new ObjectMappingLayout();
        objectMappingLayoutModel.name = 'Test';
        objectMappingLayoutModel.description = 'Test';
        objectMappingLayoutModel.isDefault = false;

        //Parent Mapping
        Object_Mapping_Template__c oppToOrderTemplate =
                ObjectMappingTemplateDataFactory.createObjectMappingTemplate('Test','Opportunity','Order',true);
        ObjectMapping oppToOrderObjectMappingModel = new ObjectMapping();
        ObjectMappingTemplate oppToOrderObjectMappingTemplateModel = new ObjectMappingTemplate();
        oppToOrderObjectMappingTemplateModel.id = oppToOrderTemplate.Id;

        oppToOrderObjectMappingModel.template = oppToOrderObjectMappingTemplateModel;
        objectMappingLayoutModel.parentMapping = oppToOrderObjectMappingModel;
        //Child Mapping 1
        Object_Mapping_Template__c lineItemOrderItemTemplate=
                ObjectMappingTemplateDataFactory.createObjectMappingTemplate('Test','OpportunityLineItem','OrderItem',true);
        ObjectMapping lineItemOrderItemMappingModel = new ObjectMapping();
        ObjectMappingTemplate lineItemOrderItemTemplateModel = new ObjectMappingTemplate();
        lineItemOrderItemTemplateModel.id = lineItemOrderItemTemplate.Id;

        lineItemOrderItemMappingModel.targetObjectRelationship = new ObjectRelationship('OpportunityLineItems','OpportunityId');
        lineItemOrderItemMappingModel.sourceObjectRelationship = new ObjectRelationship('OrderItems','OrderId');
        lineItemOrderItemMappingModel.template = lineItemOrderItemTemplateModel;
        //Child Mapping 2
        Object_Mapping_Template__c noteEmailMessageTemplate =
                ObjectMappingTemplateDataFactory.createObjectMappingTemplate('Test','Note','EmailMessage',true);
        ObjectMapping noteEmailMessageMappingModel = new ObjectMapping();
        ObjectMappingTemplate noteEmailMessageTemplateModel = new ObjectMappingTemplate();
        noteEmailMessageTemplateModel.id = noteEmailMessageTemplate.Id;

        noteEmailMessageMappingModel.targetObjectRelationship = new ObjectRelationship('Notes','ParentId');
        noteEmailMessageMappingModel.sourceObjectRelationship = new ObjectRelationship('Emails','RelatedToId');
        noteEmailMessageMappingModel.template = noteEmailMessageTemplateModel;
        //Add ChildMappings to Object Mapping Layout
        objectMappingLayoutModel.childMappings = new List<ObjectMapping>{lineItemOrderItemMappingModel, noteEmailMessageMappingModel};

        return objectMappingLayoutModel;
    }

    public static ObjectMappingLayoutResult createObjectMappingLayoutWithParentAndChildMapping(){
        //Create templates
        Object_Mapping_Template__c parentObjectMappingTemplate = ObjectMappingTemplateDataFactory.createObjectMappingTemplate(
                'OppToOrderTemplate', 'Opportunity', 'Order', true);
        Object_Mapping_Template__c childObjectMappingTemplate = ObjectMappingTemplateDataFactory.createObjectMappingTemplate(
                'OppLineToOrderItemTemplate', 'OpportunityLineItem', 'OrderItem', true);
        //Create layout
        Object_Mapping_Layout__c mappingLayout = ObjectMappingLayoutDataFactory.createObjectMappingLayout('Test layout', true);

        //Create object mappings
        Object_Mapping__c parentObjectMapping = ObjectMappingLayoutDataFactory.createObjectMapping(mappingLayout.Id,parentObjectMappingTemplate.Id, true);

        Object_Mapping__c childObjectMapping = ObjectMappingLayoutDataFactory.createObjectMapping(mappingLayout.Id,childObjectMappingTemplate.Id, false);
        childObjectMapping.External_Id__c = 'Test_External_Id__c';
        childObjectMapping.Filter_State_JSON__c = '{"logicalCondition":"AND","filterString":" Quantity = 2 ", "filterStringWithBinds":"Quantity = :value1",' +
                '"filterList":[{"operatorValue":"2","bindVariable":"value1","operator":"=","index":"1","id":"1676903873233",' +
                '"field":{"type":"DOUBLE","required":true,"referenceTo":null,"parentField":null,"labelName":"Quantity","apiName":"Quantity"}}],' +
                '"logicalOrder":"1"}';
        childObjectMapping.Source_Object_Relationship_JSON__c = '{"relationshipName":"OpportunityLineItems","fieldApiName":"OpportunityId"}';
        childObjectMapping.Target_Object_Relationship_JSON__c = '{"relationshipName":"OrderItems","fieldApiName":"OrderId"}';
        insert childObjectMapping;

        //update mappingLayout
        mappingLayout.Parent_Object_Mapping__c = parentObjectMapping.Id;
        update mappingLayout;

        ObjectMappingLayoutResult result = new ObjectMappingLayoutResult();
        result.objectMappingLayout = mappingLayout;
        result.parentObjectMappingTemplate = parentObjectMappingTemplate;
        result.childObjectMappingTemplates = new List<Object_Mapping_Template__c>{childObjectMappingTemplate};
        result.parentObjectMapping = parentObjectMapping;
        result.childObjectMappings = new List<Object_Mapping__c>{childObjectMapping};
        return result;

    }
    public class ObjectMappingLayoutResult{
        public Object_Mapping_Layout__c objectMappingLayout;
        public Object_Mapping_Template__c parentObjectMappingTemplate;
        public List<Object_Mapping_Template__c> childObjectMappingTemplates;
        public Object_Mapping__c parentObjectMapping;
        public List<Object_Mapping__c> childObjectMappings;
    }
}