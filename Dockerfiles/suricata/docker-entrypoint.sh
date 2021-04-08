#!/bin/sh
# Update suricata rules

if [ "$enable_suricata_update" = true ]; then
    if [ -n "$rule_sources" ]; then
        echo "enabling suricata-update rules with specified sources: $rule_sources"
        su - suricata -s /bin/sh -c "suricata-update update-sources"
        IFS=","; for I in $rule_sources; do su - suricata -s /bin/sh -c "suricata-update enable-source $I"; done
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

unset ARGS IFS

if [ "$enable_pcap_log" = true ]; then
    ARGS="${ARGS} --set outputs.5.pcap-log.enabled=yes"
fi

if [ "$enable_fast_log" = true ]; then
    ARGS="${ARGS} --set outputs.0.fast.enabled=yes"
fi

if [ "$enable_eve_log" = true ]; then
    ARGS="${ARGS} --set outputs.1.eve-log.enabled=yes"
fi

if [ "$enable_test_mode" = true ]; then
    echo "alert ip any any -> any any (msg:\"traffic logged\";sid:999;rev:1;)" > /var/lib/suricata/rules/testmode.rules 
fi

exec /usr/bin/suricata --user suricata --group suricata -q 0 $ARGS $@
