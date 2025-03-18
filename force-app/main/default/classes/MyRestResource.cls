@RestResource(urlMapping='/testMe/*')
global with sharing class MyRestResource {

    
  
    @HttpGet
    global static Integer doGet() {
        return 1;
    }
  
  
}