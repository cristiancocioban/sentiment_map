public class AccountController {
    @AuraEnabled
    public static AccountsResult findAll(String filter, String page, String searchAccountName, String isUSA, String groupBy, String sentimentFilter, String activityFilter) {
    	SettingsService tSettingsService = new SettingsService();

        List<Account> accounts = new List<Account>();
        List<FilterController.FilterItem> filterItems;
        String filterClauses = '';
        String tSearchAccountName = String.valueOf(searchAccountName);

        if(null != filter){     
        	FilterHelper tFilterHelper = new FilterHelper();   	
            filterClauses = tFilterHelper.buildWhereClause(filter, isUSA);
        }        
        Integer pageNo = 1;
        if(null != page) {
        	Integer tpage = Integer.valueOf(String.valueOf(page));
        	pageNo = tpage - 1;
        }
        Integer offset = pageNo * 5;	

		FilterHelper tFilterHelper = new FilterHelper();
		FilterHelper.SentimentFilter tSentimentFilter = (FilterHelper.SentimentFilter)JSON.deSerialize(sentimentFilter, FilterHelper.SentimentFilter.Class);     
		FilterHelper.ActivityFilter tActivityFilter = (FilterHelper.ActivityFilter)JSON.deSerialize(activityFilter, FilterHelper.ActivityFilter.Class); 
        
        String query = 'SELECT Id, Name, Address_Latitude__c, Address_Longitude__c, Last_Activity_Date__c, ';
        query       += 'Sentiment_Label__c, Activity_Level__c ';
		query	    += 'FROM Account ';
        query	    += 'WHERE Address_Latitude__c != NULL AND Address_Longitude__c != NULL ';

		if('1' == isUSA) query	    += 'AND State__c <> null AND State__c <> \'N/A\' ';
		else query	    += 'AND Country_Code__c <> null AND Country_Code__c <> \'N/A\' ';
        
		String sentimentFilterClause = '';
		String activityFilterClause = '';
		if(tSettingsService.SentimentAnalysisEnabled) {
			sentimentFilterClause = tFilterHelper.getSentimentFilter(tSentimentFilter);
			if('' != sentimentFilterClause) query += ' AND ' + sentimentFilterClause;

			activityFilterClause = tFilterHelper.getActivityFilter(tActivityFilter);
			if('' != activityFilterClause) query += ' AND ' + activityFilterClause;
		}

		if(null != searchAccountName && '' != searchAccountName) query += ' AND Name LIKE  \'%' + searchAccountName + '%\'';

        query       += filterClauses + ' ';
        query	    += 'ORDER By Name ';
        query	    += 'LIMIT 5 OFFSET ' + String.valueOf(offset);
        
		accounts = (List<Account>)Database.query(query);
		List<AccountItem> accountItems = new List<AccountItem>();
		for(Account tAccount: accounts) {
			AccountItem tAccountItem = new AccountItem();
			if(tSettingsService.SentimentAnalysisEnabled) { }
			else {
				tAccount.Sentiment_Label__c = 'positive';
				tAccount.Activity_Level__c = 'Moderate';				
			}

			tAccountItem.Id = tAccount.Id;
			tAccountItem.Name = tAccount.Name;
			tAccountItem.Address_Latitude = tAccount.Address_Latitude__c; 
			tAccountItem.Address_Longitude = tAccount.Address_Longitude__c; 
			tAccountItem.Last_Activity_Date = tAccount.Last_Activity_Date__c; 
			tAccountItem.Sentiment_Label = tAccount.Sentiment_Label__c; 
			tAccountItem.Activity_Level = tAccount.Activity_Level__c;

			accountItems.add(tAccountItem);
		}
			
        String queryCount = 'SELECT count(Id) accountsCount ';
        queryCount	    += 'FROM Account ';
        queryCount	    += 'WHERE Address_Latitude__c != NULL AND Address_Longitude__c != NULL ';
		if('1' == isUSA) queryCount	    += 'AND State__c <> null AND State__c <> \'N/A\' ';
		else queryCount	    += 'AND Country_Code__c <> null AND Country_Code__c <> \'N/A\' ';
        if(null != searchAccountName && '' != searchAccountName) queryCount += ' AND Name LIKE  \'%' + searchAccountName + '%\'';

		if(tSettingsService.SentimentAnalysisEnabled) {
			if('' != sentimentFilterClause) queryCount += ' AND ' + sentimentFilterClause;
			if('' != activityFilterClause) queryCount += ' AND ' + activityFilterClause;
		}

        queryCount       += filterClauses + ' ';

        AggregateResult[] results = (AggregateResult[])Database.query(queryCount);       
        Integer accountsCount = (Integer)(results[0].get('accountsCount'));
        
        AccountsResult tAccountsResult = new AccountsResult();
        tAccountsResult.Accounts = accountItems;
        tAccountsResult.AccountsCount = accountsCount;
         
        return tAccountsResult;
    }

    @AuraEnabled
	public static SettingsService getSettings() {					
		return new SettingsService();
	}	
	
	public class AccountsResult {
		@AuraEnabled
		List<AccountItem> Accounts { get; set; }
		
		@AuraEnabled
		Integer AccountsCount { get; set; }
	}

	public class AccountItem {
		@AuraEnabled
		public String Id;
		@AuraEnabled
		public String Name;
		@AuraEnabled
		public Decimal Address_Latitude; 
		@AuraEnabled
		public Decimal Address_Longitude; 
		@AuraEnabled
		public DateTime Last_Activity_Date; 
		@AuraEnabled
		public String Sentiment_Label; 
		@AuraEnabled
		public String Activity_Level;		
	}
}