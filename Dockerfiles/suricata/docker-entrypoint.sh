#!/bin/sh
if [ "$enable_suricata_update" = true ]; then
    if [ -n "$rule_sources" ]; then
        echo "enabling suricata-update rules with specified sources: $rule_sources"
        su - suricata -s /bin/sh -c "suricata-update update-sources"
        IFS=","; for I in $rule_sources; do su - suricata -s /bin/sh -c "suricata-update enable-source $I"; done
        unset IFS
        su - suricata -s /bin/sh -c "suricata-update"
        crond
        echo "0 * * * * su - suricata -s /bin/sh -c \"suricata-update update-sources && suricata-update --reload-command='suricatasc -c reload-rules'\" > /dev/null 2>&1" > /etc/crontabs/suricata-update-cron
    else 
        echo "enabling suricata-update rules with no specified sources"
        su - suricata -s /bin/sh -c "suricata-update"
        crond
        echo "0 * * * * su - suricata -s /bin/sh -c \"suricata-update --reload-command='suricatasc -c reload-rules'\" > /dev/null 2>&1" > /etc/crontabs/suricata-update-cron
    fi
    crontab /etc/crontabs/suricata-update-cron
fi

suricata_conf=/etc/suricata/suricata.yaml

if [ "$enable_pcap_log" = true ]; then
    echo "enable_pcap_log=true"
    index=$(yq eval '.outputs[] | select .pcap-log | path | .[-1]' $suricata_conf) yq eval '.outputs[env(index)].pcap-log.enabled ="yes"' -i $suricata_conf
fi

if [ "$enable_fast_log" = true ]; then
    echo "enable_fast_log=true"
    index=$(yq eval '.outputs[] | select .fast | path | .[-1]' $suricata_conf) yq eval '.outputs[env(index)].fast.enabled ="yes"' -i $suricata_conf
fi

if [ "$enable_eve_log" = true ]; then
    echo "enable_eve_log=true"
    index=$(yq eval '.outputs[] | select .eve-log | path | .[-1]' $suricata_conf) yq eval '.outputs[env(index)].eve-log.enabled ="yes"' -i $suricata_conf

fi

if [ "$enable_test_mode" = true ]; then
    echo "enable_test_mode=true"
    echo "alert ip any any -> any any (msg:\"traffic logged\";sid:999;rev:1;)" > /var/lib/suricata/rules/testmode.rules 
fi

sed -i '1 i\%YAML 1.1\n---' $suricata_conf #yq strips necessary headers so we recreate them. https://github.com/mikefarah/yq/issues/351 
chown suricata:suricata $suricata_conf

exec /usr/bin/suricata --user suricata --group suricata -q 0 $@