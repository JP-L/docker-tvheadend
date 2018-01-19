FROM debian:buster
MAINTAINER JP Limpens <jpmw.limpens@jp-l.org>

# Tvheadend package version
ARG TVHEADEND_VER="stable-4.2"
# Tvheadend package distribution
ARG TVHEADEND_DIST="stretch"
# Tvheadend bintray GPG key
ARG TVHEADEND_GPG="--keyserver hkp://keyserver.ubuntu.com:80 --recv-keys 379CE192D401AB61"
# user
ARG USR="hts"
ARG GROUP="video"
ARG HOME="/home/${USR}"

VOLUME /config /epg /recordings

# Add sysctl due to network issue on synology docker
ADD config/sysctl.conf /etc/sysctl.conf
# Add sysctl due to network issue on synology docker
#ADD config/superuser /tmp/superuser
# Add etc/init.d/tvheadend replacement due to no udev
ADD config/tvheadend /tmp/tvheadend

RUN \
  echo "**** install required packages ****" && \
  apt-get -y update && apt-get -y install \
    autoconf \
    libtool \
    git \
    build-essential \
    libargtable2-dev \
    libavformat-dev \
    libsdl1.2-dev \
    libargtable2-0 \
    locales \
  	psmisc \
  	wget \
  	cron \
  	dirmngr && \
  echo "**** install bintray's GPG key ****" && \
  apt-key adv ${TVHEADEND_GPG} && \
  echo "**** add tvheadend repository ****" && \
  echo "deb https://dl.bintray.com/tvheadend/deb ${TVHEADEND_DIST} ${TVHEADEND_VER}" | tee -a /etc/apt/sources.list && \
  echo "**** install tvheadend ****" && \
  apt-get -y update && DEBIAN_FRONTEND=noninteractive apt-get -y install \
  	xmltv-util \
  	dvb-apps \
  	tvheadend && \
  #echo "**** add IPv6 support to Tvheadend ****" && \
  #sed -i "s/^TVH_IPV6=0/TVH_IPV6=1/" /etc/default/tvheadend && \
  echo "**** change Tvheadend config path to ${HOME}/config ****" && \
  sed -i "s/^TVH_CONF_DIR=\"\"/TVH_CONF_DIR=\"\/config\"/" /etc/default/tvheadend && \
  echo "**** change Tvheadend logging to /var/log/tvheadend ****" && \
  sed -i "s/^TVH_ARGS=\"\"/TVH_ARGS=\"-l \/var\/log\/tvheadend.log\"/" /etc/default/tvheadend && \
  echo "**** Download the tv_grab file for wg++ and save it as /usr/bin/tv_grab_wg++ ****" && \
  wget -O /usr/bin/tv_grab_wg++ http://www.webgrabplus.com/sites/default/files/tv_grab_wg.txt && \
  echo "**** Set xmltv guide location in tv_grab_wg++ file to /epg ****" && \
  sed -i "s/^xmltv_file_location=~\/.wg++\/guide.xml/xmltv_file_location=\/home\/hts\/epg\/guide.xml/" /usr/bin/tv_grab_wg++ && \
  echo "**** Make the tv_grab_wg++ file executable ****" && \
  chmod +x /usr/bin/tv_grab_wg++ && \
  echo "***** build comskip ****" && \
	git clone git://github.com/erikkaashoek/Comskip /tmp/comskip && \
	cd /tmp/comskip && \
	./autogen.sh && \
	./configure \
	--bindir=/usr/bin \
	--sysconfdir=${HOME}/config/comskip && \
	make && \
	make install && \
	echo "**** add hts user to group video and users ****" && \
	usermod -a -G users hts && usermod -a -G video hts && \
  #echo "**** set superuser for tvheadend for inital login ****" && \
  #mkdir -p ${HOME}/.hts/tvheadend && \
  #mv /tmp/superuser ${HOME}/.hts/tvheadend/ && \
  #chown -R ${USR}:${GROUP} ${HOME}/.hts/ && \
  echo "**** replace /etc/init.d/tvheadend ****" && \
  mv /tmp/tvheadend /etc/init.d/tvheadend && \
  chmod 755 /etc/init.d/tvheadend && \
  echo "**** create log file if this not exists ****" && \
  [ ! -f /var/log/tvheadend.log ] && touch /var/log/tvheadend.log && \
  chmod 666 /var/log/tvheadend.log && \
  echo "**** set localtime to Amsterdam time ****" && \
  cp /usr/share/zoneinfo/Europe/Amsterdam /etc/localtime && \
  echo "**** cleanup for root ****" && \
  rm -rf \
		/tmp/* \
		/var/lib/apt/lists/* \
		/var/tmp/*
   
# Expose ports
EXPOSE 9981 9982
# Run the command on container startup
CMD /etc/init.d/tvheadend start && tail -f /var/log/tvheadend.log