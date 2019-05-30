# SFDX  import accounts
sfdx force:data:tree:import -p data/sfdx-out/export-demo-Account-plan.json -u dev2_sentiment_map

# SFDX  import insights aggregate
sfdx force:data:tree:import -p data/sfdx-out/export-demo-sentiment_map_Aggregate__mdt-plan.json -u dev2_sentiment_map

# sfdx push
sfdx force:source:deploy -u dev1_sentiment_map -p force-app/main/default


#unlocked package
sfdx force:package:create --name "Sentiment Map" --packagetype Unlocked --path force-app -v cc_dev_hub
Package Id  0Ho4P0000008OJmSAM

#create scratch org
sfdx force:org:create -s -f config/project-scratch-def.json -a dev2_sentiment_map -v cc_dev_hub
sfdx force:source:push -f -u dev3_sentiment_map