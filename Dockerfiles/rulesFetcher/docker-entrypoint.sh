#!/bin/bash
shopt -s extglob
IFS=","

removeRuleSources () {
    for I in /var/lib/suricata/update/sources/*; do
        source=$(grep "source:" $I | sed -e 's/source: //')
        if [[ ! "$rule_sources_to_be_used" = *$source* ]]; then
            suricata-update remove-source --suricata-version 6.0.2 $source
        fi
    done
}

#et/open is enabled by default. This function is a fix to remove et/open if it's not specified to be used. https://forum.suricata.io/t/suricata-update-use-only-local-rules/399/3 
etOpenFix () {
    if [[ ! "$rule_sources_to_be_used" = *et/open* ]]; then
        echo "et/open not found in rule source list. Removing."
        suricata-update remove-source --suricata-version 6.0.2 et/open
    fi
}

while :
do
    #Update rules from rulesets
    rule_sources_to_be_used=$(aws ssm get-parameter --name $RulesetsSsmParameter --region $REGION --output text --query Parameter.Value 2> /dev/null)


    if [[ ! -z "$rule_sources_to_be_used" ]]; then
        #Fetches and updates sources from https://www.openinfosecfoundation.org/rules/index.yaml
        suricata-update update-sources --suricata-version 6.0.2
        #Enabled new rule sources
        for I in $rule_sources_to_be_used; do 
            I="${I##*( )}"
            suricata-update enable-source --suricata-version 6.0.2 $I
        done
        removeRuleSources
        etOpenFix
    else
        removeRuleSources
        etOpenFix
    fi


    aws s3 cp s3://$DynamicRulesS3Path /var/lib/suricata/rules/dynamic.rules
    suricata-update -f --suricata-version 6.0.2 --url file:///dev/null
    sleep 10
done