public without sharing class FlowTestClass {

    @InvocableMethod(label='Create Account')
    public static void createAccount(){
        insert new Account(Name = 'Account created by Apex class called via flow');
    }
}