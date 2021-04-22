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

exec /usr/bin/suricata --user suricata --group suricata -q 0 $@