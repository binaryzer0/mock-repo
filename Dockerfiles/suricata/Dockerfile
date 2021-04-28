FROM public.ecr.aws/amazonlinux/amazonlinux:2.0.20210326.0-amd64

RUN amazon-linux-extras install -y epel && \
  yum -y install gcc libpcap-devel pcre-devel libyaml-devel file-devel \
  zlib-devel jansson-devel nss-devel libcap-ng-devel libnet-devel tar make \
  libnetfilter_queue-devel lua-devel PyYAML libmaxminddb-devel rustc cargo cronie \
  lz4-devel gzip && \
  yum clean all && \
  rm -rf /var/cache/yum /var/lib/suricata/rules

WORKDIR /tmp
RUN curl -s https://www.openinfosecfoundation.org/download/suricata-6.0.0.tar.gz -o suricata-6.0.0.tar.gz && \
  tar -zxvf suricata-6.0.0.tar.gz && \
  cd suricata-6.0.0 && \
  ./configure --disable-gccmarch-native --prefix=/ --sysconfdir=/etc/ --localstatedir=/var/ --enable-lua --enable-geoip --enable-nfqueue && \
  make install install-conf && \
  mkdir -p /var/lib/suricata/update/ && \
  rm -rf /tmp/*

COPY docker-entrypoint.sh rules-updater.sh /

RUN  groupadd --gid 1000 suricata && \
  useradd --gid 1000 --uid 1000 --create-home suricata && \
  chown -R suricata:suricata /etc/suricata && \
  chown -R suricata:suricata /var/log/suricata && \
  chown -R suricata:suricata /var/lib/suricata && \
  chown -R suricata:suricata /var/run/suricata && \
  touch /tmp/rules.md5 && \
  chmod +x /docker-entrypoint.sh /rules-updater.sh

#Copy config files to container, overwriting default configs.
COPY --chown=suricata:suricata ./etc/suricata/ /etc/suricata/

#Copy static rules to container
COPY --chown=suricata:suricata static.rules /var/lib/suricata/static/rules/static.rules

VOLUME /var/log/suricata

ENTRYPOINT ["/docker-entrypoint.sh"]