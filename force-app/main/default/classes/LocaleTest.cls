public with sharing class LocaleTest {
    public static String testLocale(){
        Date testDate = Date.today();
        System.System.debug(testDate.format());
        return testDate.format();
    }
}