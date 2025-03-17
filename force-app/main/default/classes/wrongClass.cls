public with sharing class wrongClass {
    public wrongClass() {

    }
    public static void insertRecords(List<Id> ids){
        List<Account> accs = new List<Account>();
        //some comment
        for (Id id : ids){
            accs.add([SELECT Id, Name FROM Account WHERE Id = :id]);
        }

        for (Account a : accs){
            a.name = 'test';
            update a;
        }
    }
}
