public with sharing class AccauntCreator {
    @AuraEnabled
    public static Map<Account, String> insertAccounts(List<Account> accs){
        system.debug(accs);
        system.debug(accs.size());
        try{
            insert accs;
        }catch(exception ex){
            System.debug(ex);
        }
        return null;
    }

    @AuraEnabled
    public static Map<Account, String> insertAccount(Account acc){

        try{
            insert acc;
        }catch(exception ex){
            System.debug(ex);
        }
        return null;
    }

    @AuraEnabled
    public static List<Account> getAccs(){
        return [SELECT Name FROM Account LIMIT 20];
    }
}