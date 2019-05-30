({
    doInit: function(component, event, helper) {
	    helper.doInit(component, event); 
	},

	loadWorld : function(component, event, helper) {
        	helper.loadWorld(component, event);		
	},

	loadUSA : function(component, event, helper) {
        	helper.loadUSA(component, event);
	},

	handleMapStateSelectedEvent: function(component, event, helper) {		
		//helper.updateChartComponent(component, event);
		helper.loadMetrics(component, event);
	},

})