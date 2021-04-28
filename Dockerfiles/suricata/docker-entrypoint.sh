#!/bin/sh
echo "* * * * * su - suricata -s /bin/sh -c \"flock -n /tmp/cron.lock /rules-updater.sh\" >/proc/1/fd/1 2>/proc/1/fd/2" > /etc/cron.d/rules-updater.sh
crontab /etc/cron.d/rules-updater.sh

exec /usr/bin/suricata --user suricata --group suricata -q 0 $@