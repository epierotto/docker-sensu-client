FROM ubuntu:trusty
MAINTAINER Exequiel Pierotto <epierotto@abast.es>

# Install sensu
RUN \
	apt-get update &&\
        apt-get install wget -y && \
	wget -qO - http://repos.sensuapp.org/apt/pubkey.gpg | apt-key add - && \
	echo "deb     http://repos.sensuapp.org/apt sensu main" > /etc/apt/sources.list.d/sensu.list && \
	apt-get update && \
	DEBIAN_FRONTEND=noninteractive apt-get install -y sensu \
	nagios-plugins
# TODO
# https://www.monitoring-plugins.org/download/monitoring-plugins-2.1.1.tar.gz
# http://edcint.co.nz/checkwmiplus/sites/default/files/check_wmi_plus.v1.59.tar.gz
# http://www.openvas.org/download/wmi/wmi-1.3.14.tar.bz2
# http://techedemic.com/2012/11/05/installing-wmic-in-ubuntu-12-04-lts-64-bit-desktop/
# make "CPP=gcc -E -ffreestanding"
# apt-get install libconfig-inifiles-perl \
# libdatetime-perl libset-scalar-perl build-essential perl-base libtemplate-plugin-number-format-perl \
# apt-get install autoconf openssh-server

# Add the sensu-server config files
COPY files/client.json /etc/sensu/client.json
COPY files/conf.d /etc/sensu/conf.d

# SSL sensu-client settings
COPY files/ssl/cert.pem /etc/sensu/ssl/cert.pem
COPY files/ssl/key.pem /etc/sensu/ssl/key.pem
COPY files/plugins /etc/sensu/plugins

RUN \
	chmod +x /etc/sensu/plugins/* && \
	chgrp -R sensu /etc/sensu

# Sync with a local directory or a data volume container
#VOLUME /etc/sensu

CMD /opt/sensu/bin/sensu-client -c /etc/sensu/client.json -d /etc/sensu/conf.d
