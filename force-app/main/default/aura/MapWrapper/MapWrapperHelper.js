({
	doInit : function(component, event) {
		var actionSettings = component.get("c.getSentimentMapSettings");  
		var self = this;
        actionSettings.setCallback(this, function(actionResult) {
			var settingsService = actionResult.getReturnValue();
			component.set('v.settingsService', settingsService);
			var settings = settingsService.Settings;

			settings.Default_Map_Region__c == 'USA'

			self.loadUSA(component, event);

        });

        $A.enqueueAction(actionSettings); 
	},
    
    
	loadUSA : function(component, event) {
		var isUSA = window.localStorage.getItem('isUSA');
        var mapRegionEvent = $A.get("e.c:MapWorldRegionEventType");
		mapRegionEvent.setParams({
    		  "region": 'USA'
		});

		this.loadMetrics(component, event);

        mapRegionEvent.fire();		
	},    

	loadMetrics : function(component, event) {
		var isUSA = localStorage.getItem('isUSA');
		var filter = this.getFilter();
		var self = this;

        var sentimentFilter = {};
		sentimentFilter.Positive = localStorage.getItem('positiveSentiment');
		sentimentFilter.Neutral = localStorage.getItem('neutralSentiment');
		sentimentFilter.Negative = localStorage.getItem('negativeSentiment');

        var activityFilter = {};

		var actionCount = component.get("c.getMetrics");
        actionCount.setParams({ filter: JSON.stringify(filter),
											  isUSA: isUSA,
											  groupBy: 'Count',
											  sentimentFilter: JSON.stringify(sentimentFilter),
											  activityFilter: JSON.stringify(activityFilter)												
											  });      
        actionCount.setCallback(this, function(actionResult) {
            var count = actionResult.getReturnValue();
			component.set('v.Count', count);
        });
        $A.enqueueAction(actionCount); 
		
	},

    getFilter: function(component) {    
		var selectedStates = window.localStorage.getItem('filter.selectedStates') == 'null' ? '':window.localStorage.getItem('filter.selectedStates');     
 

        var filter = [
            {
                Value: selectedStates,
                Type: 'States'                    
            }		    			            
        ];		
        
        return filter;
	}
})