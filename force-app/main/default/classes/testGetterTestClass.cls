@isTest
public class testGetterTestClass {
	@isTest
    public static void someMethod(){
        GetterTestClass g = new GetterTestClass();
        g.getData();
        g.getGlobalData4();
        g.getGlobalData5();
        g.getGlobalData6();
        
        g.setGlobalData4('test');
        g.setGlobalData5('test');
        g.setGlobalData6('test');
    }
}