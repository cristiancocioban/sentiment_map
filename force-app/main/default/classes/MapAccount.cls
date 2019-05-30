public class MapAccount  {    	
	@AuraEnabled
    public String Id { get; set; }
    	
    @AuraEnabled
    public String Name { get; set; }
    	
    @AuraEnabled
    public String Latitude { get; set; }
    	
    @AuraEnabled
    public String Longitude { get; set; }  

    @AuraEnabled
    public String SentimentLabel { get; set; }      
		
    @AuraEnabled
    public String ActivityLevel { get; set; }  	

}