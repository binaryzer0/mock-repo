#!/bin/sh
if [ "$enable_suricata_update" = true ]; then
    if [ -n "$rule_sources" ]; then
        #rule_sources=$(aws ssm get-parameter --name example2 --region eu-north-1 --output text --query Parameter.Value 2> /dev/null)
        echo "enabling suricata-update rules with specified sources: $rule_sources"
        su - suricata -s /bin/sh -c "suricata-update update-sources"
        IFS=","; for I in $rule_sources; do su - suricata -s /bin/sh -c "suricata-update enable-source $I"; done
        unset IFS
        su - suricata -s /bin/sh -c "suricata-update"
        crond
        echo "0 * * * * su - suricata -s /bin/sh -c \"suricata-update update-sources && suricata-update --reload-command='suricatasc -c reload-rules'\" > /dev/null 2>&1" > /etc/cron.d/suricata-update-cron
    else 
        echo "enabling suricata-update rules with no specified sources"
        su - suricata -s /bin/sh -c "suricata-update"
        crond
        echo "0 * * * * su - suricata -s /bin/sh -c \"suricata-update --reload-command='suricatasc -c reload-rules'\" > /dev/null 2>&1" > /etc/cron.d/suricata-update-cron
    fi
    crontab /etc/cron.d/suricata-update-cron
fi

exec /usr/bin/suricata --user suricata --group suricata -q 0 $@