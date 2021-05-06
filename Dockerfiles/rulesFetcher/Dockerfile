
FROM public.ecr.aws/amazonlinux/amazonlinux:2.0.20210326.0-amd64

RUN yum -y install python-pip awscli && \
  yum clean all && \
  rm -rf /var/cache/yum /etc/cron.*/* && \
  pip install --upgrade suricata-update

COPY docker-entrypoint.sh /

RUN  groupadd --gid 1000 suricata && \
  useradd --gid 1000 --uid 1000 --create-home suricata && \
  mkdir -p /var/lib/suricata/rules && \
  chown -R suricata:suricata /var/lib/suricata && \
  chmod +x /docker-entrypoint.sh /suricata-update-cron.sh

VOLUME /var/lib/suricata/rules

ENTRYPOINT ["/docker-entrypoint.sh"]