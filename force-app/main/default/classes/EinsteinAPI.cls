public class EinsteinAPI {
    public String tokenEndpoint {
        get {
            EinsteinAPISettings__c settings =
            		EinsteinAPISettings__c.getInstance(UserInfo.getOrganizationId());
            return settings.TokenEndpoint__c;
        }
    }
    
    public Decimal tokenExpirationSeconds {
        get {
            EinsteinAPISettings__c settings =
            		EinsteinAPISettings__c.getInstance(UserInfo.getOrganizationId());
            return settings.TokenExpirationSeconds__c;
        }
    }
    
    public String registeredEmail {
        get {
            EinsteinAPISettings__c settings =
            		EinsteinAPISettings__c.getInstance(UserInfo.getOrganizationId());
            return settings.RegisteredEmail__c;
        }
    }
    
    public String sentimentEndpoint {
        get {
            EinsteinAPISettings__c settings =
            		EinsteinAPISettings__c.getInstance(UserInfo.getOrganizationId());
            return settings.SentimentEndpoint__c;
        }
    }
    
    public String sentimentModelId {
        get {
            EinsteinAPISettings__c settings =
            		EinsteinAPISettings__c.getInstance(UserInfo.getOrganizationId());
            return settings.SentimentModelId__c;
        }
    }
    
    public String getAccessToken() {
    	ContentVersion base64Content = null;
    	String access_token = null;
    	
        List<ContentVersion> listContent = [
            SELECT  Title, VersionData
            FROM    ContentVersion
            WHERE   Title = 'einstein_platform'
            OR      Title = 'predictive_services'
            ORDER BY Title
            LIMIT 1
        ];
        if(listContent.size() > 0)  {  	 
	        base64Content = [
	            SELECT  Title, VersionData
	            FROM    ContentVersion
	            WHERE   Title = 'einstein_platform'
	            OR      Title = 'predictive_services'
	            ORDER BY Title
	            LIMIT 1
	        ];
	        
	        String keyContents = base64Content.VersionData.tostring();
	        keyContents = keyContents.replace('-----BEGIN RSA PRIVATE KEY-----', '');
	        keyContents = keyContents.replace('-----END RSA PRIVATE KEY-----', '');
	        keyContents = keyContents.replace('\n', '');
	        JWT jwt = new JWT('RS256');
	        jwt.pkcs8 = keyContents; 
	        jwt.iss = 'developer.force.com';
	        jwt.sub = registeredEmail;
	        jwt.aud = tokenEndpoint;
	        jwt.exp = String.valueOf(tokenExpirationSeconds);
	        access_token = JWTBearerFlow.getAccessToken(tokenEndpoint, jwt);
	        return access_token;
        }
        
        return access_token;
    }
    
    public SentimentAnalysisResponse findSentiment(String text) {
		SentimentAnalysisResponse resp;
		
		if(null != sentimentEndpoint) {		
	        String key = getAccessToken();        
	        Http http = new Http();        
	        HttpRequest req = new HttpRequest();
	        req.setMethod('POST');
	        req.setEndpoint(sentimentEndpoint);
	        req.setHeader('Authorization', 'Bearer ' + key);
	        req.setHeader('Content-type', 'application/json');        
	        String body = '{\"modelId\":\"'+ sentimentModelId + '\",\"document\":\"' + text + '\"}';
	        req.setBody(body);        
	        if(Test.isRunningTest()) {
				resp = new SentimentAnalysisResponse();
				resp.probabilities = new List<SentimentAnalysisResponse.Probabilities>();
				SentimentAnalysisResponse.Probabilities probs = new SentimentAnalysisResponse.Probabilities();
				probs.label = 'positive';
				probs.probability = 0.99;
				resp.probabilities.add(probs);
			}
			else { 
				HTTPResponse res = http.send(req);        
				resp =
	        		(SentimentAnalysisResponse) JSON.deserialize(res.getBody(), SentimentAnalysisResponse.class);
			}
		}
		
        return resp;
    }
}