public with sharing class testIcuController {
    @AuraEnabled
    public static Account testLocale(){
        Account a = new Account(name = 'test', 	testNMSPC__test_currency__c = 120, testNMSPC__test_date__c = date.today(), 
                                testNMSPC__test_date_time__c = date.today());
        return a;
    }
}