global class EinsteinService {
    public SentimentAnalysisResponse findSentiment(String text) {
        EinsteinAPI api = new EinsteinApi();        
        SentimentAnalysisResponse resp = api.findSentiment(text);        
        return resp;
    }
    
	
}