public with sharing class AccountRemoter {

    public String accountName { get; set; }
    public static jsonAccessTest account { get; set; }
    public static jsonAccessTest varbl { get; set; }
    public AccountRemoter() { 
        account =  (jsonAccessTest)json.deserialize('{"testData": "test"}', jsonAccessTest.class);
    } // empty constructor
    
    @RemoteAction
    public static jsonAccessTest getAccount(String testObject) {
        system.debug(testObject);
        account = (jsonAccessTest)json.deserialize(testObject, jsonAccessTest.class);
        system.debug(account);
        return (jsonAccessTest)json.deserialize(testObject, jsonAccessTest.class);
    }
}