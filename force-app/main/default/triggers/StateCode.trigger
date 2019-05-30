trigger StateCode on Account (before insert, before update)  { 
	Map<String, US_States_Codes__mdt> mapStateCodes = new Map<String, US_States_Codes__mdt>();
	Map<String, US_States_Codes__mdt> mapCodesState = new Map<String, US_States_Codes__mdt>();
	US_States_Codes__mdt [] stateCodes = [SELECT DeveloperName, Label , Code__c FROM US_States_Codes__mdt];

	for(US_States_Codes__mdt stateCode: stateCodes) {
		mapStateCodes.put(stateCode.Label.toLowerCase(), stateCode);
		mapCodesState.put(stateCode.Code__c.toLowerCase(), stateCode);
	}
		
	for(Account tAccount: trigger.new){
		String stateName;
		if(null != tAccount.BillingState) stateName = tAccount.BillingState.toLowerCase();
		if(null == stateName) 
			if(null != tAccount.ShippingState)
				stateName = tAccount.ShippingState.toLowerCase();
			
		if(null != stateName) {
			if(mapStateCodes.containsKey(stateName)) {
				if(mapStateCodes.get(stateName).Code__c != tAccount.State__c) {
					if(null != mapStateCodes.get(stateName)) {
						tAccount.State__c = mapStateCodes.get(stateName).Code__c;
						tAccount.BillingCountry = 'USA';
						tAccount.Country_Code__c = 'USA';
					}  
				} else {
						tAccount.BillingCountry = 'USA';
						tAccount.Country_Code__c = 'USA';
				}
			} else {
				if(mapCodesState.containsKey(stateName)) {
					tAccount.State__c = mapCodesState.get(stateName).Code__c;
					tAccount.BillingCountry = 'USA';
					tAccount.Country_Code__c = 'USA';
				} else {
					tAccount.State__c = 'N/A';
				}
			}			
		}	 

	}

}