public with sharing class InvocableMethods {
    @InvocableMethod(label='Insert Accounts' description='Inserts the accounts specified and returns the IDs of the new accounts.' category= 'Account')
    public static List<ID> insertAccounts(List<Account> accounts) {
        Database.SaveResult[] results = Database.insert(accounts);
        List<ID> accountIds = new List<ID>();
        for (Database.SaveResult result : results) {
        if (result.isSuccess()) {
            accountIds.add(result.getId());
        }
        }
        return accountIds;
    }
}