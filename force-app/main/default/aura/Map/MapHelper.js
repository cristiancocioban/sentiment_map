({    
	loadStatesData : function(component, event, filter) {
		var isUSA = window.localStorage.getItem('isUSA');
		var groupBy = 'Count';   
        var statesData;

        if(undefined === window.geoJSON) return;
		if(isUSA == "1") statesData = window.geoJSON.getJSONUSA();
		else statesData = window.geoJSON.getJSONWorld();
        component.set("v.showSpinner", true);
        var sentimentFilter = {};
		sentimentFilter.Positive = localStorage.getItem('positiveSentiment');
		sentimentFilter.Neutral = localStorage.getItem('neutralSentiment');
		sentimentFilter.Negative = localStorage.getItem('negativeSentiment');

        var activityFilter = {};
		 
        var action = component.get("c.getStatesData");

        filter.forEach(function(f){
        	if(f.Type == 'States') {
        		f.Value = '';
        	}
		});
		
        action.setParams({ statesData: JSON.stringify(statesData),
        				   filter: JSON.stringify(filter),
						   isUSA: isUSA,
						   groupBy: groupBy,
						   sentimentFilter: JSON.stringify(sentimentFilter),
						   activityFilter: JSON.stringify(activityFilter) });
        var self = this;
        action.setCallback(this, function(actionResult) {
            window.setTimeout($A.getCallback(function() {
				var event = component.getEvent("statesDataLoadedEvent");
                event.setParams({"statesData": actionResult.getReturnValue()});
                event.fire();                  
                window.localStorage.setItem('fromLoadStates', '1');
            }), 10);            
        });
        
        $A.enqueueAction(action);    		
	},
    
    // get color depending on population density value
    getColor: function (d, component) {
		/*var legendItems = component.get('v.legendItems');
		for(var i = 0; i < legendItems.length; i++) {
			if('' != legendItems[i].To__c &&
			   null != legendItems[i].To__c &&
			   undefined != legendItems[i].To__c) {
				if(d>=legendItems[i].From__c && d<=legendItems[i].To__c) {
					return legendItems[i].Color__c;
				}			
			} else {
				return legendItems[i].Color__c;
			}
		}*/

		if(d<0.45) return '#99b3ff';
		else if(d>=0.45 && d<0.55) return '#ffffe6';
		else return '#ff8080';
    },
    
    getInfo: function(component, map, L) {
		var existingInfo = component.get('v.info');		
		if(existingInfo) {
			//existingInfo.update();
			return existingInfo;
		}	
		    	
        var info = L.control();
    
        info.onAdd = function (map) {
            this._div = L.DomUtil.create('div', 'info');
            //this.update();
            return this._div;
        };
       
        
        info.update = function (props) {

        	var count = component.get('v.count');
        	
            this._div.innerHTML = '<div id="info" style="padding:2px;width:150px;background: rgb(255, 255, 255);border: 1px solid rgb(221, 219, 218);border-radius: .25rem;background-clip: padding-box;box-shadow: 0 2px 2px 0 rgba(0, 0, 0, 0.1);">' +  
                					'<div style=";text-align:center;background-color:rgba(0, 68, 135, 1.0);color: rgb(255, 255, 255);">' + '<div  style="color:white;text-decoration:none;cursor:pointer;"><b>' + count + ' accounts in total</b></div>' + '</div>' +
                					(props ? '<div style="padding:2px;">' + props.name + '</div><div style="padding:2px;">' + (props.density ? props.density:'0') + ' accounts found </div>'  : '') +
                				  '</div>';
        };
        
        //info.addTo(map);
        component.set('v.info', info);
        
		return info;        
    },
    
	getLegend: function(component, map, L) {  
		var existingLegend = component.get('v.legend');		
		if(existingLegend) return existingLegend;	
		
        var legend = L.control({position: 'bottomright'});
    	var self = this;
        legend.onAdd = function (map) {

            var div = L.DomUtil.create('div', 'info legend'),
                labels = [],
                from, to;
			
			var grades = [];
			var legendItems = component.get('v.legendItems');
			for(var itmIndex = 0; itmIndex < legendItems.length; itmIndex++) {
				grades.push(legendItems[itmIndex].From__c);
			}

    		var legend_items = '';
            for (var i = 0; i < grades.length; i++) {
                from = grades[i];
                to = grades[i + 1];
    
                labels.push(
                    '<div style="clear:both; ">'+
                    	'<div style="background:' + legendItems[i].Color__c + ';float:left;width:18px;height:18px"></div>'+
                    	'<div style="float:left;padding-left:5px;"> ' +
                    			from + (to ? '&ndash;' + to : '+') + 
                    	'</div>'+
                    	'<div style="clear:both"></div>'+                    
                    '</div>');
            }
    
            div.innerHTML = '<div style="padding:5px;width:150px;background: rgb(255, 255, 255);border: 1px solid rgb(221, 219, 218);border-radius: .25rem;background-clip: padding-box;box-shadow: 0 2px 2px 0 rgba(0, 0, 0, 0.1);">' + 
                				labels.join(' ') +
                			'</div>';
            return div;
        };
        
        //legend.addTo(map);   
        component.set('v.legend', legend);
        
        return legend;        
    },
    
    style: function (feature, component) {
           	return {
                weight: 2,
                opacity: 1,
                color: 'white',
                dashArray: '3',
                fillOpacity: 0.7,
                fillColor: this.getColor(feature.properties.density, component)
            };
    },
    
    highlightFeature: function (e, info) {
    	var layer = e.target;
    
        layer.setStyle({
                weight: 5,
                color: '#666',
                dashArray: '',
                fillOpacity: 0.7
        });
    
        if (!L.Browser.ie && !L.Browser.opera && !L.Browser.edge) {
        	layer.bringToFront();
        }
    
        //if(null != info) info.update(layer.feature.properties);
   },

   zoomToFeature: function(component, map, e, L, mapStateSelectedEvent) {
	    var stateKey = e.target.feature.properties.key;

        var selectedMarker = component.get("v.selectedMarker"); 
        if(null != selectedMarker) map.removeLayer(selectedMarker);
	    	    
	    this.removeMarkers(component, map);
	    var markers = [];
 
         	     		
   		map.fitBounds(e.target.getBounds());
	    		 	

	    var mMarkers = e.target.feature.markers;
		var markersRegistry = {};            
		for(var i = 0; i < mMarkers.length; i++) {						
			var account = mMarkers[i];
		    
			var sentiment = 'disappointed';
	        if(account.SentimentLabel == 'negative') {
	        	sentiment = 'sad';
	        
	        } else if(account.SentimentLabel == 'positive') {
	        	sentiment = 'happiness';
	        }

	        if(undefined === account.ActivityLevel || null === account.ActivityLevel) account.ActivityLevel = 'moderate';
			var myIcon = L.icon({				
           		iconUrl: $A.get('$Resource.emoji') + '/' + sentiment + '_no_color'  + '.svg',
				iconSize: [24, 24]
			});  

			var marker = L.marker([account.Latitude, account.Longitude], {icon: myIcon, id: account.Id}).addTo(map);
			marker.SentimentLabel = account.SentimentLabel;
			marker.ActivityLevel = account.ActivityLevel;

			marker.bindPopup("<b>" + account.Name + "</b><br/><br/><a href='/" + account.Id + "' target='_blank'>Details</a>")
			markers.push(marker);
			markersRegistry[account.Id] = marker;
		}              
		component.set("v.markers", markers); 
		component.set("v.markersRegistry", markersRegistry); 
		
		map.eachLayer(function(layer){
			try {
				//layer.fire('mouseover');
				//layer.fire('mouseout');
			}
			catch(e) {}
			
		});
   },   
 
   removeMarkers: function(component, map) {
        var markers = component.get("v.markers");
    	if(null != markers) {
        	markers.forEach(function(marker) {
               	map.removeLayer(marker);
            });
            markers = [];
            component.set("v.markers", markers);       
        }     
	},
	
    getFilter: function(component) {
        var selectedStates = window.localStorage.getItem('filter.selectedStates'); 

        var filter = [
            {
                Value: selectedStates,
                Type: 'States'                    
            } 						            
        ];		
        
        return filter;
	},	
 })