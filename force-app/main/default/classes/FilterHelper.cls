public class FilterHelper {
	public String buildWhereClause(String filter, String isUSA) {
        String filterClauses = '';
        List<FilterController.FilterItem> filterItems;
        
        if(null != filter){
            filterItems = (List<FilterController.FilterItem>)JSON.deSerialize(filter, List<FilterController.FilterItem>.Class);             
            for(FilterController.FilterItem item: filterItems) {
            	if(null != item && (null != item.Value || null != item.MinValue || null != item.MaxValue)) {
					if(null == item.Value) item.Value = '';
					if(null == item.MinValue) item.MinValue = '';
					if(null == item.MaxValue) item.MaxValue = '';

            	    String value = String.escapeSingleQuotes(item.Value);
	                
	                
	                if('Users' == item.Type && '' != value) {
	                    filterClauses += ' AND CreatedBy.Id = \'' + value + '\''; 
	                }      
	                
	                if('States' == item.Type && '' != value) {
	                    if('1' == isUSA) filterClauses +=  ' AND State__c = \'' + value + '\'';
						else  filterClauses += ' AND Country_Code__c = \'' + value + '\'';
	                     
	                }        											    		
            	}   	                       
            } 
        }
        System.debug('filterClauses: ' + filterClauses);
        return filterClauses;		
	}    

	public String getSentimentFilter(SentimentFilter tSentimentFilter) {
		String filter = '';
		String filterIN = '';
		String filterNOTIN = '';

		if(tSentimentFilter.Negative != '1' && tSentimentFilter.Positive != '1' && tSentimentFilter.Neutral != '1')
			return filter;
			
		if(tSentimentFilter.Negative == '1') {
			filterIN = filterIN + '\'negative\'';
		}
		else {
			filterNOTIN = filterNOTIN + '\'negative\'';
		}

		if(tSentimentFilter.Positive == '1') {
		    if('' != filterIN) filterIN = filterIN + ',';
			filterIN = filterIN + '\'positive\'';
		}
		else { 
		    if('' != filterNOTIN) filterNOTIN = filterNOTIN + ',';
			filterNOTIN = filterNOTIN + '\'positive\'';
		}

		if(tSentimentFilter.Neutral == '1') {
			if('' != filterIN) filterIN = filterIN + ',';
			filterIN = filterIN + '\'neutral\'';
		}
		else {
			if('' != filterNOTIN) filterNOTIN = filterNOTIN + ',';
			filterNOTIN = filterNOTIN + '\'neutral\'';
		}

		if('' != filterIN) filter = ' Sentiment_Label__c IN (' + filterIN + ')';
		if('' != filterNOTIN){ 
			if('' != filterIN) filter =  filter + ' AND ';
			filter = filter + ' Sentiment_Label__c NOT IN (' + filterNOTIN + ')'; 
			
		}

		return filter;
	}


	public String getActivityFilter(ActivityFilter tActivityFilter) {
		String filter = '';
		String filterIN = '';
		String filterNOTIN = '';
		
		if(tActivityFilter.Low != '1' && tActivityFilter.Moderate != '1' && tActivityFilter.High != '1')
			return filter;		

		if(tActivityFilter.Low == '1') {
			filterIN = filterIN + '\'Low\'';
		}
		else {
			filterNOTIN = filterNOTIN + '\'Low\'';
		}

		if(tActivityFilter.High == '1') {
		    if('' != filterIN) filterIN = filterIN + ',';
			filterIN = filterIN + '\'High\'';
		}
		else { 
		    if('' != filterNOTIN) filterNOTIN = filterNOTIN + ',';
			filterNOTIN = filterNOTIN + '\'High\'';
		}

		if(tActivityFilter.Moderate == '1') {
			if('' != filterIN) filterIN = filterIN + ',';
			filterIN = filterIN + '\'Moderate\'';
		}
		else {
			if('' != filterNOTIN) filterNOTIN = filterNOTIN + ',';
			filterNOTIN = filterNOTIN + '\'Moderate\'';
		}

		if('' != filterIN) filter = ' Activity_Level__c IN (' + filterIN + ')';
		if('' != filterNOTIN){ 
			if('' != filterIN) filter =  filter + ' AND ';
			filter = filter + ' Activity_Level__c NOT IN (' + filterNOTIN + ')'; 
			
		}

		return filter;
	}

	public class SentimentFilter {
		@AuraEnabled
		public String Positive { get; set; }

		@AuraEnabled
		public String Neutral { get; set; }

		@AuraEnabled
		public String Negative { get; set; }		
	}

	public class ActivityFilter {
		@AuraEnabled
		public String High { get; set; }

		@AuraEnabled
		public String Moderate { get; set; }

		@AuraEnabled
		public String Low { get; set; }		
	}
}