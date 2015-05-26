FROM ubuntu:trusty
MAINTAINER Exequiel Pierotto <epierotto@abast.es>

# RabbitMQ Environmental config
ENV RABBITMQ_SSL_CERT /etc/sensu/ssl/cert.pem
ENV RABBITMQ_SSL_KEY /etc/sensu/ssl/key.pem
ENV RABBITMQ_HOST rabbitmq.service.consul
ENV RABBITMQ_PORT 5671
ENV RABBITMQ_VHOST /sensu
ENV RABBITMQ_USER sensu
ENV RABBITMQ_PASSWORD sensu

# Sensu client Environmental config
ENV SENSU_NAME default_client
ENV SENSU_ADDRESS 127.0.0.1
ENV SENSU_SUBSCRIPTIONS all:some:another

# Sensu client checks config
# ENV GIT_REPOS 'https://github.com/epierotto/docker-rabbitmq.git'

# Add the start-up script
ADD /files/bin /usr/local/bin
RUN chmod +x /usr/local/bin/*


# Install sensu
RUN \
	apt-get update && \
        apt-get install -y  wget && \
	wget -qO - http://repos.sensuapp.org/apt/pubkey.gpg | apt-key add - && \
	echo "deb     http://repos.sensuapp.org/apt sensu main" > /etc/apt/sources.list.d/sensu.list && \
	apt-get update && \
	DEBIAN_FRONTEND=noninteractive apt-get install -y sensu


# Install plugins dependencies
RUN \
        apt-get install -y build-essential gcc make autoconf git perl-base openssh-server nmap  && \
	apt-get install -y libssl-dev dnsutils nmap snmp traceroute telnet libconfig-inifiles-perl && \
	apt-get install -y fping libdatetime-perl libset-scalar-perl libtemplate-plugin-number-format-perl && \
	apt-get install -y libmysqlclient-dev libnet-snmp-perl time libnagios-plugin-perl 

# Install monitoring-plugins
# https://www.monitoring-plugins.org/download/monitoring-plugins-2.1.1.tar.gz
RUN \
	cd /usr/local/src && \
	wget https://www.monitoring-plugins.org/download/monitoring-plugins-2.1.1.tar.gz && \
	tar xvfz monitoring-plugins-2.1.1.tar.gz && \
	cd /usr/local/src/monitoring-plugins-2.1.1 && \
	./configure && \
	make && \
	make install

# Install wmic
# http://techedemic.com/2012/11/05/installing-wmic-in-ubuntu-12-04-lts-64-bit-desktop/
RUN \
	cd /usr/local/src && \
	wget http://www.openvas.org/download/wmi/wmi-1.3.14.tar.bz2 && \
	tar xvf wmi-1.3.14.tar.bz2 && \
	cd /usr/local/src/wmi-1.3.14  && \
	sed -i '13iZENHOME=\/' GNUmakefile && \
	make "CPP=gcc -E -ffreestanding"

# Install check_wmi_plus.pl
# http://edcint.co.nz/checkwmiplus/sites/default/files/check_wmi_plus.v1.59.tar.gz
RUN \
	cd /usr/local/libexec && \
	wget http://edcint.co.nz/checkwmiplus/sites/default/files/check_wmi_plus.v1.59.tar.gz && \
	tar xvfz check_wmi_plus.v1.59.tar.gz && \
	mv check_wmi_plus.conf.sample check_wmi_plus.conf && \
	sed -i 's/\/opt\/nagios\/bin\/plugins/\/usr\/local\/libexec/g' check_wmi_plus.pl && \
	sed -i 's/\/usr\/lib\/nagios\/plugins/\/usr\/local\/libexec/g' check_wmi_plus.pl

# Add the sensu-server config files
COPY files/client.json /etc/sensu/client.json
ADD files/conf.d /etc/sensu/conf.d

# SSL sensu-client settings
ADD /files/ssl /etc/sensu/ssl

# Add custom plugins
ADD files/plugins /etc/sensu/plugins

RUN \
	chmod +x /etc/sensu/plugins/* && \
	chgrp -R sensu /etc/sensu

# Sync with a local directory or a data volume container
VOLUME /etc/sensu

CMD ["sensu-client"]
