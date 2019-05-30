public class FilterController {
     @AuraEnabled
     public static FilterComponents getAccountFilterComponents() {
      	FilterComponents components = new FilterComponents();
        components.States = getStates();
		 
        return components;
     }        

     @AuraEnabled
     public static List <FilterItem> getStates() {
        List<FilterItem> filterItems = new List<FilterItem> ();
         
        List<US_States_Codes__mdt> states = [SELECT Code__c, MasterLabel, DeveloperName FROM US_States_Codes__mdt ORDER BY MasterLabel];
        if(null != states) {
            
            for(US_States_Codes__mdt tState: states) {
            	FilterItem item = new FilterItem();
                item.Value = tState.Code__c;
                item.Label = tState.MasterLabel;
                filterItems.add(item);
            }   
        }
         
      	return filterItems;
     }      	   
    
     public static List <FilterItem> getFilterItems(sObject objObject, string fld) {
      	List<FilterItem> filterItems = new List<FilterItem> ();

      	Schema.sObjectType objType = objObject.getSObjectType();
      	Schema.DescribeSObjectResult objDescribe = objType.getDescribe();
      	Map<String, Schema.SObjectField> fieldMap = objDescribe.fields.getMap();

      	List<Schema.PicklistEntry> values = fieldMap.get(fld).getDescribe().getPickListValues();
      	for (Schema.PicklistEntry listEntry: values) {
            FilterItem item = new FilterItem();
            item.Value = listEntry.getValue();
            item.Label = listEntry.getLabel();
        	filterItems.add(item);
      	}
         
      	filterItems.sort();
      	return filterItems;
     }    
    
     public class FilterItem implements Comparable {         
        @AuraEnabled
        public String Label { get; set; }
         
        @AuraEnabled
        public String Value { get; set; }

        @AuraEnabled
        public Boolean Selected { get; set; }   

        @AuraEnabled
        public String MinValue { get; set; }

        @AuraEnabled
        public String MaxValue { get; set; }
         
        @AuraEnabled
        public String Type { get; set; }           
         
    	public Integer compareTo(Object compareTo) {
            FilterItem compareToEmp = (FilterItem)compareTo;
            if (Label == compareToEmp.Label) return 0;
            if (Label > compareToEmp.Label) return 1;
            return -1;        
    	}         
     }    
    
     public class FilterComponents {         
        @AuraEnabled 
        public List<FilterItem> States { get; set; } 

     }     
}