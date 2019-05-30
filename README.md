#create scratch org
sfdx force:org:create -s -f config/project-scratch-def.json -a dev1_sentiment_map -v cc_dev_hub
sfdx force:source:push -f -u dev1_sentiment_map

# SFDX  import accounts
sfdx force:data:tree:import -p data/sfdx-out/export-demo-Account-plan.json -u dev1_sentiment_map