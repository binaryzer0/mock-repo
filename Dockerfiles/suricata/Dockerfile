FROM alpine:3.13

RUN apk add python3 py-pip suricata=6.0.1-r1 --no-cache && \
    pip install suricata-update && \
    ## Remove standard rules as default. Set env enable_suricata_update=true when launching container to re-add and automatically keep the rule list up to date.
    rm -rf /var/lib/suricata/rules/suricata.rules /var/lib/suricata/update/ && \ 
    addgroup suricata && \
    adduser -S -u 100 -G suricata suricata && \
    chown -R suricata:suricata /etc/suricata && \
    chown -R suricata:suricata /var/log/suricata && \
    chown -R suricata:suricata /var/lib/suricata && \
    chown -R suricata:suricata /var/run/suricata

#Copy config files to container, overwriting default configs.
COPY --chown=suricata:suricata ./configs/etc/suricata/suricata.yaml /etc/suricata/

#Copy your own rules to container
COPY --chown=suricata:suricata ./configs/var/lib/suricata/rules/my.rules /var/lib/suricata/rules/

COPY docker-entrypoint.sh /
ENTRYPOINT ["/docker-entrypoint.sh"]

