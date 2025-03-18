global class GetterTestClass {
    
    global String name { get; set; }
    global GetterTestClass(){
        name = 'test name';
        publicData1 = 'publicData1';
        
        globalData1 = 'globalData1';
        globalData2 = 'globalData2';
        globalData3 = 'globalData3';
        globalData4 = 'globalData4';
        globalData5 = 'globalData5';
        globalData6 = 'globalData6';
        globalData7 = 'globalData7';
        globalData8 = 'globalData8';
        globalData9 = 'globalData9';

    }
    global GetterTestClass getData()
    {
        GetterTestClass result = new GetterTestClass();
        result.name = this.name; 
        return result;
        
        
    } 
    
    public String publicData1{public get; public set;}
    
    global String globalData1{public get; global set;}
    global String globalData2{global get; public set;}
    global String globalData3{public get; public set;}
    global String globalData4;
    
    global String getGlobalData4(){
        return globalData4;
    }
    
    public void setGlobalData4(String globalData4){
        this.globalData4 = globalData4 + 'done by the public set method';
    }
    
    global String globalData5;
    
    public String getGlobalData5(){
        return globalData4;
    }
    
    global void setGlobalData5(String globalData4){
        this.globalData5 = globalData5;
    }
    
    global String globalData6;
    
    global String getGlobalData6(){
        return globalData6;
    }
    
    public void setGlobalData6(String globalData6){
        this.globalData6 = globalData6 + 'done by the public set method';
    }
    
    global String globalData7{public get{return globalData7;} global set{globalData7 = value;}}
    global String globalData8{global get{return globalData8;} public set{globalData8 = value;}}
    global String globalData9{public get{return globalData9;} public set{globalData9 = value;}}
    
}