#!/bin/bash

#Update rules from rulesets
rule_sources=$(aws ssm get-parameter --name $RulesetsSsmParameter --region $REGION --output text --query Parameter.Value 2> /dev/null)
current_sources=$(cat /tmp/enabled.rules)

oldIFS=$IFS
IFS=","

if [[ -z "$rule_sources" ]]; then
    #Fetches and updates sources from https://www.openinfosecfoundation.org/rules/index.yaml
    suricata-update update-sources --suricata-version 6.0.2
    #Enabled new rule sources
    for I in $rule_sources; do 
        suricata-update enable-source --suricata-version 6.0.2 $I; 
    done
fi

#Remove old rule sources
for I in $current_sources; do 
    if [[ ! "$rule_sources" =~ "$I" ]]; then
        suricata-update remove-source --suricata-version 6.0.2 $I
    fi
done

IFS=$oldIFS
echo $rule_sources > /tmp/enabled.rules

suricata-update -f

#Download dynamic rules from s3
aws s3 cp s3://$DynamicRulesS3Path /var/lib/suricata/rules/dynamic.rules