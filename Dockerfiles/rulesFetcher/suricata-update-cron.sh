#!/bin/bash

#Update rules from rulesets
rule_sources=$(aws ssm get-parameter --name $RulesetsSsmParameter --region $REGION --output text --query Parameter.Value 2> /dev/null)
su - suricata -s /bin/sh -c "suricata-update update-sources --suricata-version 6.0.2"
IFS=","; for I in $rule_sources; do su - suricata -s /bin/sh -c "suricata-update enable-source --suricata-version 6.0.2 $I"; done
unset IFS
su - suricata -s /bin/sh -c "suricata-update -f"

#Download dynamic rules from s3
aws s3 cp s3://$DynamicRulesS3Path /var/lib/suricata/rules/dynamic.rules