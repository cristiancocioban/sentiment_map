public class AccountDataQualityService  {
	public Map<String, Map<String, String>> getCountriesWithCodesValues() {
		Map<String, String> countriesWithCodes = new Map<String, String>(); 
		Map<String, String> countriesWithValues = new Map<String, String>(); 
		List<Country__mdt> countries = [SELECT DeveloperName, Name__c FROM Country__mdt];

		for(Country__mdt country: countries) {
			if(!countriesWithCodes.containsKey(country.DeveloperName.toLowerCase())) {
				countriesWithCodes.put(country.DeveloperName.toLowerCase(), country.Name__c);
			}
			if(!countriesWithValues.containsKey(country.Name__c.toLowerCase())) {
				countriesWithValues.put(country.Name__c.toLowerCase(), country.DeveloperName);
			}
		}

		Map<String, Map<String, String>> countriesWithCodesValues = new Map<String, Map<String, String>>();
		countriesWithCodesValues.put('codes', countriesWithCodes);
		countriesWithCodesValues.put('values', countriesWithValues);
		return countriesWithCodesValues;
	}

	public static List<Account> setAccountsCountryCode(List<Account> accounts) {
		AccountDataQualityService service = new AccountDataQualityService();
		Map<String, Map<String, String>> countriesWithCodesValues =  service.getCountriesWithCodesValues();
		Map<String, String> countriesWithCodes = (Map<String, String>)(countriesWithCodesValues.get('codes'));
		Map<String, String> countriesWithValues = (Map<String, String>)(countriesWithCodesValues.get('values'));

		for(Account tAccount: accounts) {
			String country = tAccount.BillingCountry;
			if(null == country || '' == country) {
				country = tAccount.ShippingCountry;
			}
			if(null != country && '' != country) {
				if(countriesWithCodes.containsKey(country.toLowerCase())) {
					tAccount.Country_Code__c = country;
				}
				else if (countriesWithValues.containsKey(country.toLowerCase())) {
					tAccount.Country_Code__c = (String)(countriesWithValues.get(country.toLowerCase()));
				}
			}
		}

		return accounts;
	}
}