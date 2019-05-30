public class MapController {
    
    @AuraEnabled
    public static String getStatesData(String statesData, String filter, String isUSA, String groupBy, String sentimentFilter, String activityFilter ) {   
		SettingsService tSettingsService = new SettingsService();

		FilterHelper.SentimentFilter tSentimentFilter = (FilterHelper.SentimentFilter)JSON.deSerialize(sentimentFilter, FilterHelper.SentimentFilter.Class);     
		FilterHelper.ActivityFilter tActivityFilter = (FilterHelper.ActivityFilter)JSON.deSerialize(activityFilter, FilterHelper.ActivityFilter.Class);     

    	FilterHelper tFilterHelper = new FilterHelper(); 	
		
		Map<String, List<MapAccount>> stateAccounts = accountsFromState(filter, isUSA, groupBy, tSentimentFilter, tActivityFilter);
		
		// get states data count
		String query = 'SELECT  count(Id) Density, sum(Sentiment__c) Sentiment, State__c ';

		query += ' FROM Account WHERE (Address_Latitude__c <> null AND Address_Longitude__c <> null)  ';  
		query += ' AND State__c <> null AND State__c <> \'N/A\' ';

		if(tSettingsService.SentimentAnalysisEnabled) {
			String sentimentFilterClause = tFilterHelper.getSentimentFilter(tSentimentFilter);
			if('' != sentimentFilterClause) query += ' AND ' + sentimentFilterClause;

			String activityFilterClause = tFilterHelper.getActivityFilter(tActivityFilter);
			if('' != activityFilterClause) query += ' AND ' + activityFilterClause;

		}

		if(null != filter) {
        	String whereClause =  tFilterHelper.buildWhereClause(filter, isUSA);
        	if('' != whereClause) query += whereClause;
        }      
		query += ' GROUP BY State__c ';  		

        AggregateResult[] results = (AggregateResult[])Database.query(query);
        Map<String, Decimal> statesDensityCount = new Map<String, Decimal>();
        for (AggregateResult ar : results)  {
            String tBillingState  = String.valueOf(ar.get('State__c'));        
            Decimal density = Decimal.valueOf(String.valueof(ar.get('Density')));
			Decimal sentiment = Decimal.valueOf(String.valueof(ar.get('Sentiment')));
			Decimal value = sentiment/density;
            statesDensityCount.put(tBillingState, value);		
        }   
		
		// update states density for map
	    Map<String, Object> tMapData = (Map<String, Object>) JSON.deserializeUntyped(statesData);
	    Map<String, Object> tMapDataUpdated = new  Map<String, Object>();
	    List<Object> features = (List<Object>)tMapData.get('features');
	    List<Object> featuresUpdated = new List<Object>();
	   	Decimal value = 0;
        for(Integer i = 0; i < features.size(); i++) {
        	Map<String, Object> feature = (Map<String, Object>)features[i];
        	Map<String, Object> properties = (Map<String, Object>)feature.get('properties');
        	String stateKey = (String)properties.get('key');
        	if(null != statesDensityCount.get(stateKey)) {
        		properties.put('density', (Decimal)statesDensityCount.get(stateKey));
        	} 
        	else {
        		properties.put('density', 0);
        	}
        	
        	feature.put('properties', properties);   
        	if(null == stateAccounts.get(stateKey)) {
        		feature.put('markers', JSON.deserializeUntyped(JSON.serialize(new List<MapAccount>())));
        	}
        	else {
        		feature.put('markers', JSON.deserializeUntyped(JSON.serialize(stateAccounts.get(stateKey))));
        	}	
        	featuresUpdated.add(feature);
        	 
        }

		
		List<Legend_Item__mdt> legendItems = getActiveLegendItems(groupBy);
    	tMapDataUpdated.put('legendItems', legendItems);   

		tMapDataUpdated.put('settingsService', tSettingsService);
		tMapDataUpdated.put('features', featuresUpdated);               
        tMapDataUpdated.put('count', 10); 
 	
        
        return JSON.serialize(tMapDataUpdated);
    }    
    
    public static Map<String, List<MapAccount>> accountsFromState(String filter, String isUSA, String groupBy, FilterHelper.SentimentFilter tSentimentFilter, FilterHelper.ActivityFilter tActivityFilter) {   
    	SettingsService tSettingsService = new SettingsService();

		Map<String, List<MapAccount>> stateAccounts = new Map<String, List<MapAccount>>();
    	FilterHelper tFilterHelper = new FilterHelper(); 	
		// get states data count
        String query = 'SELECT Id, Name, Address_Latitude__c, Address_Longitude__c, State__c, Country_Code__c, Sentiment_Label__c, Activity_Level__c  FROM Account WHERE (Address_Latitude__c <> null AND Address_Longitude__c <> null ) '; 
		query	    += ' AND State__c <> null AND State__c <> \'N/A\' ';

		if(tSettingsService.SentimentAnalysisEnabled) {
			String sentimentFilterClause = tFilterHelper.getSentimentFilter(tSentimentFilter);
			if('' != sentimentFilterClause) query += ' AND ' + sentimentFilterClause;

			String activityFilterClause = tFilterHelper.getActivityFilter(tActivityFilter);
			if('' != activityFilterClause) query += ' AND ' + activityFilterClause;
		}
		      
        if(null != filter) {
        	String whereClause =  tFilterHelper.buildWhereClause(filter, isUSA);
        	if('' != whereClause) query += whereClause;
        }      
        
    	List<Account> accounts = (List<Account>)Database.query(query);
    	for(Account tAccount: accounts) {
    		if('1' == isUSA) {
			  if(null != tAccount.State__c) { 
				if(stateAccounts.get(tAccount.State__c) == null ) stateAccounts.put(tAccount.State__c, new List<MapAccount>());
			  }
			  else continue;
			}
			else { 
				if(null != tAccount.Country_Code__c)  {
					if(stateAccounts.get(tAccount.Country_Code__c) == null ) stateAccounts.put(tAccount.Country_Code__c, new List<MapAccount>());
				}
				else continue;				
			} 

    		MapAccount mAccount = new MapAccount();
    		
    		mAccount.Id = tAccount.Id;
    		mAccount.Name = tAccount.Name;
    		mAccount.Latitude = String.valueof(tAccount.Address_Latitude__c);
    		mAccount.Longitude = String.valueof(tAccount.Address_Longitude__c);
			if(tSettingsService.SentimentAnalysisEnabled) {
				mAccount.SentimentLabel = tAccount.Sentiment_Label__c;
				mAccount.ActivityLevel = String.valueOf(tAccount.Activity_Level__c);
    		}
			else {
				mAccount.SentimentLabel = 'positive';
				mAccount.ActivityLevel = 'Moderate';				
			}
    		if('1' == isUSA) stateAccounts.get(tAccount.State__c).add(mAccount);	
			else stateAccounts.get(tAccount.Country_Code__c).add(mAccount);
    	}
    	System.debug('stateAccounts: ' + stateAccounts);
    	return stateAccounts;
    }        

    @AuraEnabled
    public static Integer getMetrics(String filter, String isUSA, String groupBy, String sentimentFilter, String activityFilter) {
	    SettingsService tSettingsService = new SettingsService();

        FilterHelper tFilterHelper = new FilterHelper();
        Integer result = 0;

		FilterHelper.SentimentFilter tSentimentFilter = (FilterHelper.SentimentFilter)JSON.deSerialize(sentimentFilter, FilterHelper.SentimentFilter.Class);     
		FilterHelper.ActivityFilter tActivityFilter = (FilterHelper.ActivityFilter)JSON.deSerialize(activityFilter, FilterHelper.ActivityFilter.Class); 

        String query = 'SELECT ';
		if('Count' == groupBy) {
			query += ' count(Id) metric ' ;
		}

		if('Total AUM' == groupBy) {
			query += ' sum('+ tSettingsService.SortedKPIAggregates[1].Field_Name__c + ') metric ' ;
		}

		if('Strategy AUM' == groupBy) {
			query += ' sum('+ tSettingsService.SortedKPIAggregates[2].Field_Name__c + ') metric ' ;
		}

		
		if('1' == isUSA) query += ' FROM Account WHERE (State__c <> null AND State__c <> \'N/A\')';
		else query += ' FROM Account WHERE (Country_Code__c <> null AND Country_Code__c <> \'N/A\')';
		query += ' AND (Address_Latitude__c <> null AND Address_Longitude__c <> null ) ';
        if(null != filter) {
        	String whereClause =  tFilterHelper.buildWhereClause(filter, isUSA);
        	if('' != whereClause) query += whereClause;
        }      

		if(tSettingsService.SentimentAnalysisEnabled) {
			String sentimentFilterClause = tFilterHelper.getSentimentFilter(tSentimentFilter);
			if('' != sentimentFilterClause) query += ' AND ' + sentimentFilterClause;

			String activityFilterClause = tFilterHelper.getActivityFilter(tActivityFilter);
			if('' != activityFilterClause) query += ' AND ' + activityFilterClause;
		}

        AggregateResult[] results = (AggregateResult[])Database.query(query);       
        for (AggregateResult ar : results)  {          
            result= Integer.valueOf(ar.get('metric'));
        }
        
        return result;
    }
    @AuraEnabled
	public static List<Legend_Item__mdt> getActiveLegendItems(String legendType) {
		
		
		// because we can't define a trigger for custom metadata we set only 1 active theme on first access of the map
		List<Legend_Theme__mdt> legendThemes = [SELECT Id, DeveloperName FROM Legend_Theme__mdt 
													WHERE Active__c = True];

		List<Legend_Item__mdt> legendItems;
		legendItems = [SELECT DeveloperName, From__c, To__c, Color__c 
					   FROM Legend_Item__mdt 
					   WHERE Legend_Theme__r.Active__c = True AND Legend_Type__c = :legendType
					   ORDER BY From__c];
		return legendItems;
	}

    @AuraEnabled
	public static SettingsService getSentimentMapSettings() {					
		return new SettingsService();
	}

	/*
		map level 0 - world
		map level 1 - country
		map level 2 - subregion1 (state for us)
		map level 3 - subregion2 (county for us) 
	*/
	@AuraEnabled
	public static String getMapFeatures(String groupByMapLevel, String selectedRegionName, String densityFieldName) {
		GeojsonService tGeojsonService = new GeojsonService();
		String geojson = tGeojsonService.getMapFeatures(groupByMapLevel, selectedRegionName, densityFieldName); 

		return geojson;
	}



}