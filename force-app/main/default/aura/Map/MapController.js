({
   jsLoaded: function(component, event, helper) {

 		var map = L.map('map').setView([0, 0], 1);
              
        L.tileLayer('https://api.tiles.mapbox.com/v4/{id}/{z}/{x}/{y}.png?access_token=pk.eyJ1IjoibWFwYm94IiwiYSI6ImNpejY4NXVycTA2emYycXBndHRqcmZ3N3gifQ.rJcFIG214AriISLbB6B5aw', {
            maxZoom: 18,
            zoomAnimation:false,
            attribution: 'Map data &copy; <a href="http://openstreetmap.org">OpenStreetMap</a> contributors, ' +
                '<a href="http://creativecommons.org/licenses/by-sa/2.0/">CC-BY-SA</a>, ' +
                'Imagery © <a href="http://mapbox.com">Mapbox</a>',
            id: 'mapbox.light'
        }).addTo(map);
        
        map.on('zoomend', function(e) {        
        	var current = map.getZoom();
        	if(current < 5) {

        	}
        });
        
    	component.set("v.map", map);
        var filter = helper.getFilter();
    	helper.loadStatesData(component, event, filter);

  },
  
  handleMapComponentStateSelectedEvent: function(component, event, helper) {
	  var selectedStateKey = component.get("v.selectedStateKey");
   	  if(null != selectedStateKey) window.localStorage.setItem('filter.selectedStates', selectedStateKey);    	
   	  else window.localStorage.setItem('filter.selectedStates', '');  	 	

      var filterAppliedEvent = $A.get("e.c:MapStateSelectedEventType");


      filterAppliedEvent.setParams({
    	  "states": selectedStateKey
      });
      
      filterAppliedEvent.fire();  	  
  },
    
  handleStatesDataLoadedEvent: function(component, event, helper) {
		var map = component.get('v.map');
        helper.removeMarkers(component, map);
		var selectedMarker = component.get("v.selectedMarker"); 
        if(null != selectedMarker) map.removeLayer(selectedMarker);

		component.set("v.showSpinner", false); 
        var self = this;
        
        var strStatesData = event.getParam('statesData');
      	var statesData = JSON.parse(strStatesData);

      	var allMarkersRegistry = {};
      	statesData.features.forEach(function(feature) {
      		feature.markers.forEach(function(account) {
      			allMarkersRegistry[account.Id] = account;
      		});
        });
      	component.set('v.allMarkersRegistry', allMarkersRegistry);
      	component.set('v.count', statesData.count);

		var geojson = component.get('v.geojson');
		
        var info = helper.getInfo(component, map, L);

		component.set('v.legendItems', statesData.legendItems);
		var legend = helper.getLegend(component, map, L); 
      
	    var isUSA = window.localStorage.getItem('isUSA');
		if(isUSA == "1") map.setView(new L.LatLng(37.8, -96), 4);
		else map.setView(new L.LatLng(0, 0), 1);
		
        function style(feature) {
            return helper.style(feature, component);
        }
    	 
        function zoomToFeature(e) {  
        	var stateKey = e.target.feature.properties.key;                	
        	var mapComponentStateSelectedEvent =  component.getEvent("mapComponentStateSelectedEvent");       	
	        component.set("v.selectedStateKey", stateKey);         
	        
	        
			var selectedMarker = component.get("v.selectedMarker"); 
			if(null != selectedMarker) map.removeLayer(selectedMarker);        	
	        helper.removeMarkers(component, map);		        
	        
	        //highlight selected feature
	        var currentSelectedFeature = component.get('v.selectedFeature');    
	        if(null !== currentSelectedFeature ){
	        	var fromApplyFilter = window.localStorage.getItem('fromApplyFilter');
	        	window.localStorage.setItem('fromApplyFilter', '0');
	        	if(null === fromApplyFilter || undefined === fromApplyFilter) fromApplyFilter = '0';
	        	if(stateKey == currentSelectedFeature.target.feature.properties.key && fromApplyFilter == '0') {
		        	geojson.resetStyle(currentSelectedFeature.target);
	        	    window.localStorage.setItem('filter.selectedRegion', '');	               	
			        
					component.set("v.selectedStateKey", null);    
			        component.set('v.selectedFeature', null);   
			        window.localStorage.setItem('filter.selectedStates', null);      

		        	var filter = helper.getFilter();
		        	helper.zoomToFeature(component, map, e, L); 
		        	helper.removeMarkers(component, map);

					var isUSA = window.localStorage.getItem('isUSA');
					if(isUSA == "1") map.setView(new L.LatLng(37.8, -96), 4);
					else map.setView(new L.LatLng(0, 0), 1);
 			        
	        	}
	        	else {
			        component.set('v.selectedFeature', e);
			        window.localStorage.setItem('filter.selectedStates', stateKey); 

			        if(null != geojson) geojson.resetStyle(currentSelectedFeature.target);

			    	var layer = e.target;
			    
			        layer.setStyle({
			                weight: 5,
			                color: '#004487',
			                dashArray: '',
			                fillOpacity: 0.7
			        });
			    
			        if (!L.Browser.ie && !L.Browser.opera && !L.Browser.edge) {
			        	layer.bringToFront();
			        }		        	
	        		helper.zoomToFeature(component, map, e, L); 
	        	}
	        	
	
	        }
	        else {
		        component.set('v.selectedFeature', e);
		        window.localStorage.setItem('filter.selectedStates', stateKey); 

		        if(null != geojson) geojson.resetStyle(e.target);
	            //info.update(e.target.feature.properties);
	
		    	var layer = e.target;
		    
		        layer.setStyle({
		                weight: 5,
		                color: '#004487',
		                dashArray: '',
		                fillOpacity: 0.7
		        });
		    
		        if (!L.Browser.ie && !L.Browser.opera && !L.Browser.edge) {
		        	layer.bringToFront();
		        }	        
			        
	            helper.zoomToFeature(component, map, e, L); 	        
	        }
	        window.localStorage.setItem('fromLoadStates', '0');
	        
	        mapComponentStateSelectedEvent.fire();  
        }
    
        function highlightFeature(e) {
            var selectedFeature = component.get('v.selectedFeature');
            if(selectedFeature != null) {
            	//info.update(selectedFeature.target.feature.properties);
	            if(e.target.feature.properties.key == selectedFeature.target.feature.properties.key)
		            return;                 
            }
            helper.highlightFeature(e, info, statesData);
        }

        function resetHighlight(e) {
            var selectedFeature = component.get('v.selectedFeature');
            if(selectedFeature != null) {
            	//info.update();
	            if(e.target.feature.properties.key == selectedFeature.target.feature.properties.key)
		            return;                 
            }
            
            geojson.resetStyle(e.target);
            //info.update();
        }
    
        function onEachFeature(feature, layer) {
			layer._leaflet_id = feature.properties.key;  
            layer.on({
                mouseover: highlightFeature,
                mouseout: resetHighlight,
                click: zoomToFeature
            });
            
            /*var selectedStates = window.localStorage.getItem('filter.selectedStates'); 
            if(undefined !== selectedStates && null != selectedStates) {
	            if(feature.properties.key == selectedStates) {
	            	layer.fire('click');
					localStorage.setItem("selectedLayer", layer);
	            }           
            }*/

        }
        
        if(geojson) map.removeLayer(geojson);
        component.set('v.statesData', statesData);
        geojson = L.geoJson(statesData, {
            style: style,
            onEachFeature: onEachFeature
        }).addTo(map);
        
        component.set('v.geojson', geojson);
    },
    
    handleFilterAppliedEvent: function(component, event, helper) {
    	window.localStorage.setItem('fromApplyFilter', '1');
		var selectedStates = window.localStorage.getItem('filter.selectedStates');
        var filter = helper.getFilter();    
        helper.loadStatesData(component, event, filter);       
    },   

	handleMapWorldRegionEvent: function(component, event, helper) {
		var region = event.getParam('region');
		if('USA' == region) window.localStorage.setItem('isUSA', '1');
		else window.localStorage.setItem('isUSA', '0');
		var filter = helper.getFilter();    
        helper.loadStatesData(component, event, filter);    
    },
    
    handleAccountItemSelectedEvent: function(component, event, helper) {
    	var nothingToFire = false;
    	var map = component.get("v.map");
    	
    	var marker;
    	var markers = component.get("v.markers");
    	var allMarkers = component.get("v.allMarkersRegistry");
    	var accountId = event.getParam('selectedAccountId');
		var account = allMarkers[accountId];

		var sentiment = 'disappointed';
	    if(account.SentimentLabel == 'negative') {
			sentiment = 'sad';
	    } else if(account.SentimentLabel == 'positive') {
	        sentiment = 'happiness';
	    }		

	    if(undefined === account.ActivityLevel || null === account.ActivityLevel) account.ActivityLevel = 'moderate';
        var myIcon = L.icon({       	
           	iconUrl: $A.get('$Resource.emoji') + '/' + sentiment +  '_no_color'  + '.svg',
            iconSize: [24, 24]
        }); 
        
        var selectedMarker = component.get("v.selectedMarker"); 
        if(null != selectedMarker) map.removeLayer(selectedMarker);
          	
    	if(null != markers && markers.length > 0) {
    		marker = markers[accountId];
    		if(null == marker){
    			var account = allMarkers[accountId];
    			marker = L.marker([account.Latitude, account.Longitude], {icon: myIcon, id: account.Id}).addTo(map);
    			marker.SentimentLabel = account.SentimentLabel;
				marker.ActivityLevel = account.ActivityLevel;
    			marker.bindPopup("<b>" + account.Name + "</b><br/><br/><a href='/" + account.Id + "' target='_blank'>Details</a>");
    			
    			component.set('v.selectedMarker', marker);
    		}
    		    	

    	}
    	else {
    		var account = allMarkers[accountId];
    		if(null != account && null != account.Latitude) {
	    		marker = L.marker([account.Latitude, account.Longitude], {icon: myIcon, id: account.Id}).addTo(map);
    			marker.SentimentLabel = account.SentimentLabel;
				marker.ActivityLevel = account.ActivityLevel;
	    		marker.bindPopup("<b>" + account.Name + "</b><br/><br/><a href='/" + account.Id + "' target='_blank'>Details</a>");
	    		component.set('v.selectedMarker', marker);    		
    		}
    		else {
    			alert('Geocode information missing.');
    			nothingToFire = true;
    		}
    	}
    		
    	if(!nothingToFire) marker.fire('click')
    },	

	handleSentimentSelectedEvent: function(component, event, helper) {
		var filter = helper.getFilter();    
        helper.loadStatesData(component, event, filter);   
    },	
})