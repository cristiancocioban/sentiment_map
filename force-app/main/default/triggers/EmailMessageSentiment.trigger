trigger EmailMessageSentiment on EmailMessage (after insert) {
	SettingsService tSettingsService = new SettingsService();

	if(tSettingsService.SentimentAnalysisEnabled) {
		Set<ID> ids = Trigger.newMap.keySet();
		EmailMessageService.updateSentiment(ids);
	}
}