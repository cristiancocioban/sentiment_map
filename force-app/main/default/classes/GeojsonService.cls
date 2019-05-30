public class GeojsonService  {
	public String getMapFeatures(String groupByMapLevel, String selectedRegionName, String densityFieldName) {
		selectedRegionName += '_geojson';
		List<StaticResource> sr = [select id,body from StaticResource Where Name = :selectedRegionName];
		String geojson;
		if(sr.size() > 0) geojson = sr[0].body.toString();
		return geojson;		
	}
}