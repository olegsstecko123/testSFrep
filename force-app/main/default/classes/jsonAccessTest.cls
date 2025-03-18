@JsonAccess(serializable='never' deserializable='always')
global class jsonAccessTest {
    
    global jsonAccessTest(String testData) { 
        this.testData = testData;
    }
    
    global String testData;
}