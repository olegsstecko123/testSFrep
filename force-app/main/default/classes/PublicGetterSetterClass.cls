public class PublicGetterSetterClass {
    
    public String name { get; set; }
    public PublicGetterSetterClass(){
        name = 'test name';
        privateData1 = 'privateData1';
        
        publicData1 = 'publicData1';
        publicData2 = 'publicData2';
        publicData3 = 'publicData3';
        publicData4 = 'publicData4';
        publicData5 = 'publicData5';
        publicData6 = 'publicData6';
        publicData7 = 'publicData7';
        publicData8 = 'publicData8';
        publicData9 = 'publicData9';

    }
    public GetterTestClass getData()
    {
        GetterTestClass result = new GetterTestClass();
        result.name = this.name; 
        return result;
        
        
    } 
    
    private String privateData1{private get; private set;}
    
    public String publicData1{private get; public set;}
    public String publicData2{public get; private set;}
    public String publicData3{private get; private set;}
    public String publicData4;
    
    public String getpublicData4(){
        return publicData4;
    }
    
    private void setpublicData4(String publicData4){
        this.publicData4 = publicData4 + 'done by the private set method';
    }
    
    public String publicData5;
    
    private String getpublicData5(){
        return publicData4;
    }
    
    public void setpublicData5(String publicData4){
        this.publicData5 = publicData5;
    }
    
    public String publicData6;
    
    public String getpublicData6(){
        return publicData6;
    }
    
    private void setpublicData6(String publicData6){
        this.publicData6 = publicData6 + 'done by the private set method';
    }
    
    public String publicData7{private get{return publicData7;} public set{publicData7 = value;}}
    public String publicData8{public get{return publicData8;} private set{publicData8 = value;}}
    public String publicData9{private get{return publicData9;} private set{publicData9 = value;}}
    

}