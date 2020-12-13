FROM debian:buster-slim

# environment settings
ARG DEBIAN_FRONTEND="noninteractive"
ENV HOME="/config" \
PYTHONIOENCODING=utf-8

RUN \
 echo "**** install apt-transport-https first ****" && \
 apt-get update && \
 apt-get install -y apt-transport-https gnupg2 curl && \
 echo "**** install packages ****" && \
 echo "deb http://ftp.nl.debian.org/debian buster main non-free" >> /etc/apt/sources.list.d/sabnzbd.list && \
 apt-get update && \
 apt-get install -y \
	libffi-dev \
	libssl-dev \
	p7zip-full \
	par2-tbb \
	python3 \
	python3-cryptography \
	python3-distutils \
	python3-pip \
        git \
	unrar && \
 echo "**** installing sabnzbd ****" && \
 cd /opt && \
 git clone https://github.com/sabnzbd/sabnzbd.git && \
 cd sabnzbd && \
 git checkout master && \
  pip3 install -U pip && \
 pip install -U --no-cache-dir \
	apprise \
	pynzb \
	requests && \
 pip install -U --no-cache-dir -r requirements.txt && \
 echo "**** cleanup ****" && \
 ln -s \
	/usr/bin/python3 \
	/usr/bin/python && \
 apt-get purge --auto-remove -y \
	libffi-dev \
	libssl-dev \
        git \
	python3-pip && \
 apt-get clean && \
 rm -rf \
	/tmp/* \
	/var/lib/apt/lists/* \
	/var/tmp/*
  
WORKDIR /opt/sabnzbd
COPY start.sh .
COPY healthcheck.sh .
RUN chmod +x *.sh

EXPOSE 8080
VOLUME /config

HEALTHCHECK --interval=5m --timeout=5s \
  CMD /opt/sabnzbd/healthcheck.sh

ENTRYPOINT ["/opt/sabnzbd/start.sh"]
