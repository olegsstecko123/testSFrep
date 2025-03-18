@isTest
public with sharing class RecordFromExcelUploadControllerTest {

    @isTest
    public static void getFieldTypes(){
        test.startTest();
            Map<String, String> acData = RecordFromExcelUploadController.getFieldTypes('Account');
        test.stopTest();
        System.assertEquals('DECIMAL',acData.get('annualrevenue'));
        System.assertEquals('STRING',acData.get('name'));
    }


    @isTest
    public static void createRecords(){
        List<Map<String, String>> Events = new List<Map<String, String>>();
        for(Integer i = 0; i < 4; i++){
            Map<String, String> e = new Map<String, String>();
            e.put('Name', 'Test ' + i);
            e.put('IsAllDayEvent', 'true');
            e.put('Phone', '1111');
            e.put('Location', 'test');
           if(i == 2){
            e.put('ActivityDate', '2070-0a-01');
            e.put('DurationInMinutes', '1440');
           }else if (i == 3){
            e.put('DurationInMinutes', '1');
            e.put('ActivityDate', '2070-01-01');
           }else{
            e.put('ActivityDate', '2070-01-01');
            e.put('DurationInMinutes', '1440');
           }
           Events.add(e);
        }
        Map<String, String> evData = RecordFromExcelUploadController.getFieldTypes('Event');
        RecordFromExcelUploadController.createRecords(Events, 'Event', evData, '','');

        System.assertEquals(2,[SELECT Id FROM Event].size());        
    }

    
}