trigger Sentiment_Map_Account on Account (before insert, before update)  { 
	List<Account> accounts = AccountDataQualityService.setAccountsCountryCode(trigger.new);
}