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
