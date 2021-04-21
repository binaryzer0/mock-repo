FROM public.ecr.aws/amazonlinux/amazonlinux:2.0.20210326.0-amd64

RUN amazon-linux-extras install -y epel && \
  yum -y install gcc libpcap-devel pcre-devel libyaml-devel file-devel \
  zlib-devel jansson-devel nss-devel libcap-ng-devel libnet-devel tar make \
  libnetfilter_queue-devel lua-devel PyYAML libmaxminddb-devel rustc cargo cronie \
  lz4-devel gzip && \
  yum clean all && \
  rm -rf /var/cache/yum

WORKDIR /tmp
RUN  curl -s -L https://github.com/mikefarah/yq/releases/download/v4.7.0/yq_linux_amd64 -o /usr/bin/yq && chmod +x /usr/bin/yq && \
  curl -s https://www.openinfosecfoundation.org/download/suricata-6.0.0.tar.gz -o suricata-6.0.0.tar.gz && \
  tar -zxvf suricata-6.0.0.tar.gz && \
  cd suricata-6.0.0 && \
  ./configure --disable-gccmarch-native --prefix=/ --sysconfdir=/etc/ --localstatedir=/var/ --enable-lua --enable-geoip --enable-nfqueue && \
  make install install-conf && \
  mkdir -p /var/lib/suricata/update/ && \
  rm -rf /tmp/*

RUN  groupadd --gid 1000 suricata && \
  useradd --gid 1000 --uid 1000 --create-home suricata && \
  chown -R suricata:suricata /etc/suricata && \
  chown -R suricata:suricata /var/log/suricata && \
  chown -R suricata:suricata /var/lib/suricata && \
  chown -R suricata:suricata /var/run/suricata

#Copy config files to container, overwriting default configs.
COPY --chown=suricata:suricata ./configs/etc/suricata/ /etc/suricata/

#Copy your own rules to container
COPY --chown=suricata:suricata ./configs/var/lib/suricata/rules/my.rules /var/lib/suricata/rules/

COPY docker-entrypoint.sh /
ENTRYPOINT ["/docker-entrypoint.sh"]