/** 
 * This class handles background actions of the RecordFromExcelUploader LWC 
 * 
 * @see RecordFromExcelUploader.js
 *
 * @author  olegs.a.stecko@accenture.com
 *
 * @version 2022-10-10  olegs.a.stecko@accenture.com       main functionality implementation
 */
public without sharing class RecordFromExcelUploadController {

    /**
     * Wrapper class to pass errors to the frontend
     */
    class errorData{
        Map<String, Object> record;
        Map<String, String> errorInfo;
    }

    /**
     * Method returns mapping table, stored in the cestom metadata record
     * 
     * @param   String developerName      Name of the custom metadata record
     * @return  String                    Mapping table
     */
    @AuraEnabled
    public static String getMappingTable(String developerName){
        String mappingTable = [SELECT Mapping_table__c FROM ExcelFileUploadCmpConfig__mdt WHERE DeveloperName = :developerName LIMIT 1].Mapping_table__c;
        Return mappingTable;
    }

    /**
     * Method returns plural label of an object to be creataed, to display it in the component header
     * 
     * @param   String objectApiName      
     * @return  String                    Object label
     */
    @AuraEnabled
    public static string getObjectName(String objectApiName){
        return (String)Schema.getGlobalDescribe().get(objectApiName).getDescribe().getLabelPlural();
    }

    /**
     * Method returns datatype of fields of the object to later parse values
     * 
     * @param   String sObjectName      
     * @return  Map<String, String>     Map of field name and datatype
     */
    @AuraEnabled
    public static Map<String, String> getFieldTypes(String sObjectName){
        Schema.SObjectType insertedObject = Schema.getGlobalDescribe().get(sObjectName);
        Map<String, Schema.SObjectField> allFields = insertedObject.getDescribe().fields.getMap();
        Map<String, String> output = new Map<String, String>();
        for(String fName : allFields.keySet()){
            switch on String.valueOf(allFields.get(fName).getDescribe().getType()) {
                when 'DATETIME'{
                    output.put(fName, 'DATE');
                }
                when 'DATE'{
                    output.put(fName, 'DATE');
                }
                when 'BOOLEAN'{
                    output.put(fName, 'BOOLEAN');
                }
                when 'INTEGER'{
                    output.put(fName, 'INTEGER');
                }
                when 'CURRENCY'{
                    output.put(fName, 'DECIMAL');
                }
                when 'DOUBLE'{
                    output.put(fName, 'DECIMAL');
                }
                when 'PERCENT'{
                    output.put(fName, 'DECIMAL');
                }
                when 'PHONE'{
                    output.put(fName, 'DECIMAL');
                }
                when else{
                    output.put(fName, 'STRING');
                }

            }
        }
        return output;
    }

    /**
     * Method parses values and inserts objects into the database
     * 
     * @param   List<Map<String, String>> records       List of records to be created
     * @param   String sObjectName                      Name of sObject to parse records to
     * @param   Map<String, String> dataTypes           Map of object fields and their datatypes 
     * @param   String className                        Name of the class with additional logic to run on records before insert 
     * @param   String methodName                       Name of the method with additional logic to run on records before insert     
     * @return  Map<String, String>     Map of field name and datatype
     */
    @AuraEnabled
    public static String createRecords(List<Map<String, String>> records, String sObjectName, Map<String, String> dataTypes, String className, String methodName){
        Schema.SObjectType insertedObject = Schema.getGlobalDescribe().get(sObjectName);
        List<sObject> objects = new List<sObject>();
        List<errorData> errors = new List<errorData>();
        String tempField;
        String tempvalue;
        //parse the data
        for(Map<String, String> record : records){
            sObject sObj = insertedObject.newSObject();
            try{
                for(String fieldName : record.keySet()){
                    tempField = fieldName;
                    tempvalue = record.get(fieldName);
                    switch on dataTypes.get(fieldName.toLowerCase()) {
                        when 'STRING'{
                            sObj.put(fieldName, tempvalue);
                        }
                        when 'DECIMAL'{
                            sObj.put(fieldName, Decimal.valueOf(tempvalue));
                        }
                        when 'INTEGER'{
                            sObj.put(fieldName, Integer.valueOf(tempvalue));
                        }
                        when 'DATE'{
                            sObj.put(fieldName, Date.valueOf(tempvalue));
                        }
                        when 'BOOLEAN'{
                            sObj.put(fieldName, Boolean.valueOf(tempvalue));
                        }
                    }
                }
                objects.add(sObj);
            }catch(Exception e){
                //all the records with wrong datatypes are returned to the frontend
                Map<String, String> description = new Map<String, String>();
                description.put('Type', 'MappingError');
                description.put('Error',  String.valueOf(e));
                description.put('Field', tempField);
                description.put('Value', tempvalue);
                errorData errorTemp = new errorData();
                errorTemp.record = record;
                errorTemp.errorInfo = description;
                errors.add(errorTemp);

            }
            
        }
        //call the aditional logic
        if(className != '' && methodName != ''){
            Callable additionalClass = (Callable) Type.forName(className).newInstance();
            Map<String,Object> args = new Map<String,Object>();
            args.put('objects', objects);
            objects = (List<SObject>)additionalClass.call(methodName, args);
        }

        Database.UpsertResult[] lsr = Database.upsert(objects, false);

        Map<sObject, String> errorMap = new Map<sObject, String>();

        //if there are any errors on the insert, they are also returned to the frontend
        for(Integer i = 0; i < lsr.size(); i++){
            if(!lsr.get(i).isSuccess()){
                Map<String, String> description = new Map<String, String>();
                description.put('Type', 'InsertError');
                description.put('Error', String.valueOf(lsr.get(i).getErrors()));

                errorData errorTemp = new errorData();
                errorTemp.record = (Map<String, Object>) JSON.deserializeUntyped(JSON.serialize(objects.get(i)));
                errorTemp.errorInfo = description;
                errors.add(errorTemp);
                
            }
        }
        return JSON.serialize(errors);

    }

    /**
     * Method is called after recods are inserted and calls additional logic that runs on the record that inserted recods are related to
     * 
     * @param   String className                        Name of the class with additional logic 
     * @param   String methodName                       Name of the method with additional logic  
     * @param   String recordId                         Id of a racord that will be changed
     */
    @AuraEnabled
    public static void runLogicAfterInsert(String className, String methodName, String recordId){
        Callable additionalClass = (Callable) Type.forName(className).newInstance();
        Map<String,Object> args = new Map<String,Object>();
        args.put('recordId', recordId);
        try {
            additionalClass.call(methodName, args);
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

}