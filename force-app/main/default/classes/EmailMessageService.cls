global class EmailMessageService {
    @future(callout=true)
    public static void updateSentiment(Set<Id> emailMessageIDs)
    {   
        List<EmailMessage> emailMessages = calculateSentimentForEmailMessages(emailMessageIDs);   	
    	update emailMessages;
    	
    	List<Account> accounts = calculateSentimentForAccount(emailMessages);
    	update accounts;
    }    
    
    private static List<EmailMessage> calculateSentimentForEmailMessages(Set<Id> emailMessageIDs) {
		EinsteinService einstein = new EinsteinService();
        List<EmailMessage> emailMessages = [SELECT Id, ActivityId, TextBody, Sentiment__c, Sentiment_Label__c 
        									FROM EmailMessage WHERE Id IN :emailMessageIDs
        									ORDER BY CreatedDate DESC];
        System.debug('emailMessages: ' + emailMessages);
    	for(EmailMessage tEmailMessage : emailMessages) {
    		if(tEmailMessage.TextBody != null) {
    			String textBody = String.escapeSingleQuotes(tEmailMessage.TextBody).replace('\n','').replace('\r','');
    			Integer maxCount = textBody.length() > 1000 ? 999:textBody.length();
	    		textBody = textBody.substring(0, maxCount);
	    		
	    		SentimentAnalysisResponse response = einstein.findSentiment(textBody);
	            tEmailMessage.Sentiment__c = 0;
	            if(null != response) {
		            System.debug('response.probabilities: ' + response.probabilities);
		            for(SentimentAnalysisResponse.Probabilities probability: response.probabilities) {
		                if(probability.probability > tEmailMessage.Sentiment__c) {
		                    tEmailMessage.Sentiment__c = probability.probability;
		                    tEmailMessage.Sentiment_Label__c = probability.label;
		                }
		                
		            }   
	            } 			
    		}
    	} 
    	
    	return emailMessages;   	
    }
      
    private static List<Account> calculateSentimentForAccount(List<EmailMessage> emailMessages) {
    	Map<Id, Account> accounts = new Map<Id, Account>();
    	Set<Id> activityIds = new Set<Id>();
    	Map<Id, EmailMessage> emailMessagesByActivityId = new Map<Id, EmailMessage>();
    	
    	for(EmailMessage tEmailMessage: emailMessages) {
    		if(tEmailMessage.TextBody != null) {
    			activityIds.add(tEmailMessage.ActivityId);	
    			emailMessagesByActivityId.put(tEmailMessage.ActivityId, tEmailMessage);
    		}    			
    	}
    	
    	List<Task> tasks = [SELECT Account.Id FROM Task WHERE Id IN :activityIds];

		for(Task tTask: tasks) {
			if(!accounts.containsKey(tTask.Account.Id)) {
				Account tAccount = new Account();
				tAccount.Id = tTask.Account.Id;
				tAccount.Sentiment__c = emailMessagesByActivityId.get(tTask.Id).Sentiment__c;
				tAccount.Sentiment_Label__c = emailMessagesByActivityId.get(tTask.Id).Sentiment_Label__c;			
				tAccount.Activity_Level__c = 'High';
				accounts.put(tTask.Account.Id, tAccount);	
			}
		}    	
		
    	return accounts.values();
    }
}