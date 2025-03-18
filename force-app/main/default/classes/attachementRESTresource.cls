@RestResource(urlMapping='/testREST/*')
global with sharing class attachementRESTresource {
    
    @HttpPost
	global static void doPost() {
		Map<String, Object> RB = (Map<String, Object>)System.JSON.deserializeUntyped(RestContext.request.requestBody.tostring());
    	
    	/*Attachment att = new Attachment(parentId = (Id)RB.get('Id'),
        							 Name = (String)RB.get('Name'), 
                                     ContentType = (String)RB.get('ContentType'),
                                     Body =  Blob.valueOf((String)RB.get('Body')));
        insert att;*/
        List<ContentVersion> CVs = new List<ContentVersion>();
        
        List<Map<String, Object>> files = new List<Map<String, Object>>();
        for (Object instance : (List<Object>)RB.get('Files')){
    		files.add((Map<String, Object>)instance); 
        }
        
        for(Map<String, Object> file : Files){
        	CVs.add(createContentVersion((String)file.get('Name'), (String)file.get('Body')));
        }
        
        Insert CVs;
        
        System.debug(CVs);
        
        List<ContentDocumentLink> CDLs = new List<ContentDocumentLink>();
        
        for(ContentVersion CV : CVs){
            CDLs.add(createContentDocumentLink(CV.ContentDocumentId, (Id)RB.get('Id'), [SELECT ContentDocumentId FROM ContentVersion WHERE Id = :CV.Id LIMIT 1].ContentDocumentId));
        }
        
        
        insert CDLs;
    }
    
    private static ContentVersion createContentVersion(String name, String body){
    	ContentVersion contentVersion = new ContentVersion();
    	contentVersion.ContentLocation = 'S'; // S = Stored in Salesforce
    	contentVersion.PathOnClient = name;
    	contentVersion.Title = name;
    	contentVersion.VersionData = EncodingUtil.base64Decode(body);
    	return contentVersion;
	}
    
    private static ContentDocumentLink createContentDocumentLink(Id contentDocumentId, Id parentId, Id CDID){
    	ContentDocumentLink contentDocumentLink = new ContentDocumentLink();
    	contentDocumentLink.ContentDocumentId = contentDocumentId;
    	contentDocumentLink.LinkedEntityId = parentId;
        contentDocumentLink.ContentDocumentId = CDID;
    	contentDocumentLink.ShareType = 'I'; // Inferred permission
    	contentDocumentLink.Visibility = 'InternalUsers';
    	return contentDocumentLink;
	}
    
    
    
}