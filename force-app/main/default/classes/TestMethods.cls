public class TestMethods {
	@future
    public static void f1(){
        Account acc = [SELECT Id, name FROM Account WHERE Id = '0017Q0000085gqEQAQ' FOR UPDATE];
        system.debug('f1' + acc);
       	acc.test_checkbox__c = true;
        acc.name = acc.name + ' updated by f1';
        update acc;
        
        Long startingTime = System.now().getTime(); // Num milliseconds since Jan 1 1970
		Integer delayInMilliseconds = 7000; 
		while (System.now().getTime() - startingTime < delayInMilliseconds)  {
            // Do nothing until desired delay has passed
 		}
    }
    
    @future
    public static void f2(){
        Account acc = [SELECT Id, name FROM Account WHERE Id = '0017Q0000085gqEQAQ' FOR UPDATE];
        system.debug('f2' + acc);
       	acc.test_checkbox__c = true;
        acc.name = acc.name + ' updated by f2';
        
        Long startingTime = System.now().getTime(); // Num milliseconds since Jan 1 1970
		Integer delayInMilliseconds = 5000; 
		while (System.now().getTime() - startingTime < delayInMilliseconds)  {
            // Do nothing until desired delay has passed
 		}
        update acc;
    }
    
    
   
}