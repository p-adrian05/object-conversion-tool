public with sharing class ObjectMappingLayoutServiceImpl implements ObjectMappingLayoutService{


    /**
    * Upserts the specified Object_Mapping_Layout__c record represented in ObjectMappingLayout
            * object with its associated Object_Mapping__c records.

            * @param objectMappingLayout - ObjectMappingLayout object to be upserted
            * @return Id - Id of the upserted ObjectMappingLayout object
            * @throws SObjectException - Throws exception if there is any issue with upserting ObjectMappingLayout record
            or its associated child or parent ObjectMappings
            */
    public Id upsertObjectMappingLayout(ObjectMappingLayout objectMappingLayout){
        ObjectUtil.requireNonNull(objectMappingLayout, 'ObjectMappingLayout cannot be null to upsert Object_Mapping_Layout__c record.');
        Object_Mapping_Layout__c objectMappingLayoutSObject = objectMappingLayout.toSObject();

        if(!Object_Mapping_Layout__c.getSObjectType().getDescribe().isCreateable()){
            throw new SObjectException('Do not have permission to create Object_Mapping_Layout__c object.');
        }
        if(!Object_Mapping_Layout__c.getSObjectType().getDescribe().isUpdateable()){
            throw new SObjectException('Do not have permission to update Object_Mapping_Layout__c object.');
        }

        //get the original associated Object_Mapping__c records before upserting
        // the Object_Mapping_Layout__c record with new Object_Mapping__c records
        List<Id> oldObjectMappingIds = new List<Id>();
        if(objectMappingLayoutSObject.Id != null){
            oldObjectMappingIds = getObjectMappingIds(objectMappingLayoutSObject.Id);
        }

        Savepoint savepoint = Database.setSavepoint();
        try{
            upsert objectMappingLayoutSObject;

            //upsert new child and parent Object_Mapping__c records
            List<Object_Mapping__c> childMappings =
                    upsertObjectMappings(objectMappingLayout.childMappings,objectMappingLayoutSObject.Id);
            List<Object_Mapping__c> parentMapping =
                    upsertObjectMappings(new List<ObjectMapping>{objectMappingLayout.parentMapping},objectMappingLayoutSObject.Id);

            if(parentMapping.size()==1){
                objectMappingLayoutSObject.Parent_Object_Mapping__c = parentMapping.get(0).Id;
                update objectMappingLayoutSObject;
            }

            //delete unlinked Object_Mapping__c records comparing old and new Object_Mapping__c records
            List<Object_Mapping__c> newObjectMappingSObjects = new List<Object_Mapping__c>();
            newObjectMappingSObjects.addAll(childMappings);
            newObjectMappingSObjects.addAll(parentMapping);
            removeUnlinkedObjectMappings(oldObjectMappingIds,newObjectMappingSObjects);

        }catch (Exception e){
            Database.rollback(savepoint);
            System.debug(e.getMessage());
            throw e;
        }

        return objectMappingLayoutSObject.Id;
    }
    /**
        This method removes unlinked Object_Mapping__c records by comparing a list of old and new Object_Mapping__c Ids.

        If an Object_Mapping__c Id from the old list is not in the new list, a new Object_Mapping__c  is created
        with the Id of the old mapping and added to a list of Object_Mapping__c records to delete.
        The list is then deleted if it contains any elements.

        @param oldObjectMappingIds List of Ids of old Object Mapping records
        @param newObjectMappingSObjects List of new Object Mapping records
        @return List of Object Mapping records to be deleted
     */
    @TestVisible
    private List<Object_Mapping__c> removeUnlinkedObjectMappings(List<Id> oldObjectMappingIds,List<Object_Mapping__c> newObjectMappingSObjects){
        List<Object_Mapping__c> objectMappingsToDelete = new List<Object_Mapping__c>();

        //get the Ids of the new Object_Mapping__c records
        Set<Id> newObjectMappingIds = new Set<Id>();
        for(Object_Mapping__c newObjectMapping:newObjectMappingSObjects){
            newObjectMappingIds.add(newObjectMapping.Id);
        }
        //compare the old and new Object_Mapping__c record ids
        for(Id oldMappingId : oldObjectMappingIds){
            if(!newObjectMappingIds.contains(oldMappingId)){
                objectMappingsToDelete.add(new Object_Mapping__c(Id=oldMappingId));
            }
        }
        //delete the unlinked Object_Mapping__c records
        if(!objectMappingsToDelete.isEmpty()){
            delete objectMappingsToDelete;
        }
        return objectMappingsToDelete;
    }
    /**
     * This method returns a list of `Id`s of `Object_Mapping__c` records
     * that are associated with the provided `Object_Mapping_Layout__c` record.
     *
     * @param mappingLayoutId The `Id` of the `Object_Mapping_Layout__c` record
     * to get the associated `Object_Mapping__c` records for.
     *
     * @return A list of `Id`s of `Object_Mapping__c` records
     * that are associated with the provided `Object_Mapping_Layout__c` record.
 */
    private List<Id> getObjectMappingIds(Id mappingLayoutId){
        List<Id> mappingIds = new List<Id>();

        for(Object_Mapping__c objectMapping:[SELECT Id FROM Object_Mapping__c WHERE Object_Mapping_Layout__c =:mappingLayoutId]){
            mappingIds.add(objectMapping.Id);
        }
        return mappingIds;
    }
    /**
        Upserts a list of Object_Mapping__c records that are represented in ObjectMapping objects.

        @param objectMappings A list of ObjectMapping objects to upsert.
        @param layoutId The ID of the Object_Mapping_Layout__c record to associate with the Object_Mapping__c records.
        @return A list of Object_Mapping__c records that were upserted.
    */
    private List<Object_Mapping__c> upsertObjectMappings(List<ObjectMapping> objectMappings,Id layoutId){
        List<Object_Mapping__c> objectMappingsSObjects = new List<Object_Mapping__c>();

        if(objectMappings!=null){
            for(ObjectMapping objectMapping:objectMappings){
                if(objectMapping!=null) {
                    objectMappingsSObjects.add(objectMapping.toSObject(layoutId));
                }
            }
        }
        if(objectMappingsSObjects.size()>0){
            upsert objectMappingsSObjects;
        }
        return objectMappingsSObjects;
    }

    /**
    Deletes an Object_Mapping_Layout__c record by the specified ID. If the layout record has a parent Object_Mapping__c,
    the parent field is first cleared to avoid deleting a parent record while a child is still referencing it.

    @param objectMappingLayoutId The ID of the Object Mapping Layout record to delete
    @throws SObjectException if an error occurs during the delete operation
    */
    public void deleteObjectMappingLayout(Id objectMappingLayoutId){
        ObjectUtil.requireNonNull(objectMappingLayoutId, 'objectMappingLayoutId cannot be null' +
                ' to delete ObjectMappingLayout.');

        if(!Object_Mapping_Layout__c.SObjectType.getDescribe().isDeletable()){
            throw new SObjectException('Do not have permission to delete Object_Mapping_Layout__c records.');
        }

        List<Object_Mapping_Layout__c> layouts = Database.query('SELECT Id, Parent_Object_Mapping__c FROM '+
                                            ' Object_Mapping_Layout__c WHERE Id = :objectMappingLayoutId');

        if(layouts.size()>0){
            Savepoint savepoint = Database.setSavepoint();
            Object_Mapping_Layout__c layout = layouts.get(0);

            try{
                if(layout.Parent_Object_Mapping__c!=null){
                    layout.Parent_Object_Mapping__c = null;
                    update layout;
                }
                delete layout;
            }catch (Exception e){
                Database.rollback(savepoint);
                System.debug(e.getMessage());
                throw e;
            }
        }
    }
    /**

    Marks the specified Object Mapping Layout as default for its parent source object.

    @param objectMappingLayoutId the Id of the Object Mapping Layout to mark as default
    @throws SObjectException if the Object Mapping Layout Id or Parent Source Object API Name is null
    */
    public void markDefaultObjectMappingLayout(Id objectMappingLayoutId){
        ObjectUtil.requireNonNull(objectMappingLayoutId, 'objectMappingLayoutId cannot be null to mark ObjectMappingLayout as default.');

        String parentSourceObjectApiName = [SELECT Parent_Source_Object_Api_Name__c FROM Object_Mapping_Layout__c
                                        WHERE Id =:objectMappingLayoutId]?.Parent_Source_Object_Api_Name__c;

        if(parentSourceObjectApiName == null){
            throw new SObjectException('Parent Source Object API Name is null or dont have access to mark it default ' +
                    'Id' + objectMappingLayoutId);
        }
        // clear all other default layouts for the parent source object
        List<Object_Mapping_Layout__c> layouts = ObjectUtil.executeQueryWithoutSharing(
                                'SELECT Id, IsDefault__c FROM Object_Mapping_Layout__c' +
                                ' WHERE Parent_Source_Object_Api_Name__c =:parentSourceObjectApiName',
                                new Map<String,Object>{'parentSourceObjectApiName'=>parentSourceObjectApiName});
        if(layouts.size()>0) {
            for(Object_Mapping_Layout__c layout : layouts){
                if(layout.Id == objectMappingLayoutId) {
                    layout.IsDefault__c = true;
                } else {
                    layout.IsDefault__c = false;
                }
            }
        }
        update layouts;
    }

}