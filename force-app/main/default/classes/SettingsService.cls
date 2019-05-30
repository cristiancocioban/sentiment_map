public class SettingsService  {
	@AuraEnabled
	sentiment_map_Settings__mdt Settings{ get; set; }
	@AuraEnabled
	public Boolean SentimentAnalysisEnabled { get; set; }

	@AuraEnabled
	public Map<String, sentiment_map_Aggregate__mdt> Aggregates { get; set; }
	@AuraEnabled
	public List<sentiment_map_Aggregate__mdt> SortedAggregates { get; set; }
		
	@AuraEnabled
	public Map<String, sentiment_map_Aggregate__mdt> RegionAggregates { get; set; }
	@AuraEnabled
	public List<sentiment_map_Aggregate__mdt> SortedRegionAggregates { get; set; }

	@AuraEnabled
	public Map<String, sentiment_map_Aggregate__mdt> KPIAggregates { get; set; }
	@AuraEnabled
	public List<sentiment_map_Aggregate__mdt> SortedKPIAggregates { get; set; }

	public SettingsService() {
		List<sentiment_map_Settings__mdt> lSettings;

		lSettings = [SELECT Id, DeveloperName, Default_Map_Region__c, Enable_Sentiment_Analysis__c
					   FROM sentiment_map_Settings__mdt];

		if(lSettings.size() > 0) {
			 Settings = lSettings[0];

			 if(Test.isRunningTest()) SentimentAnalysisEnabled = true;
			 else SentimentAnalysisEnabled = Settings.Enable_Sentiment_Analysis__c;
		}	

		this.setAggregates();
	}

	private void setAggregates() {
		RegionAggregates = new Map<String, sentiment_map_Aggregate__mdt>();
		SortedRegionAggregates = new List<sentiment_map_Aggregate__mdt>();
		KPIAggregates = new Map<String, sentiment_map_Aggregate__mdt>();
		SortedKPIAggregates = new List<sentiment_map_Aggregate__mdt>();
		Aggregates = new Map<String, sentiment_map_Aggregate__mdt>();
		SortedAggregates = [SELECT DeveloperName, MasterLabel, Category__c,
							Default__c, Field_Name__c,
							Legend_Theme__c, Object_Name__c,
							Rank__c
							FROM sentiment_map_Aggregate__mdt
							ORDER BY Rank__c];
		for(sentiment_map_Aggregate__mdt aggregate: SortedAggregates) {
			if('Region' == aggregate.Category__c) {
				RegionAggregates.put(aggregate.MasterLabel, aggregate);
				SortedRegionAggregates.add(aggregate);
			}

			if('KPI' == aggregate.Category__c) {
				KPIAggregates.put(aggregate.MasterLabel, aggregate);
				SortedKPIAggregates.add(aggregate);
			}

			Aggregates.put(aggregate.MasterLabel, aggregate);
		}
	}
}