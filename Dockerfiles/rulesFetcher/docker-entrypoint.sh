#!/bin/sh
/suricata-update-cron.sh

echo "* * * * * su - suricata -s /bin/sh -c \"flock -n /tmp/cron.lock /suricata-update-cron.sh\" >/proc/1/fd/1 2>/proc/1/fd/2" > /etc/cron.d/suricata-update-cron.sh
crontab /etc/cron.d/suricata-update-cron.sh

exec crond -n 