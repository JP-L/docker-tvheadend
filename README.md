[jplorgurl]: https://www.jp-l.org
[appurl]: https://www.tvheadend.org/
[hub]: https://hub.docker.com/r/jplorg/tvheadend/

TODO: add logo

[JP-L][jplorgurl] created a Tvheadend container featuring easy user mapping.

Latest release: 0.1 - docker-tvheadend - [Changelog](CHANGELOG.md)
# jplorg/tvheadend
[![](https://images.microbadger.com/badges/version/jplorg/tvheadend.svg)](https://microbadger.com/images/jplorg/tvheadend "Get your own version badge on microbadger.com")
[![](https://images.microbadger.com/badges/image/jplorg/tvheadend.svg)](https://microbadger.com/images/jplorg/tvheadend "Get your own image badge on microbadger.com")
[![Docker Pulls](https://img.shields.io/docker/pulls/jplorg/tvheadend.svg)][hub]
[![Docker Stars](https://img.shields.io/docker/stars/jplorg/tvheadend.svg)][hub]
TODO: Add shippable and code quality status

[![tvheadend](https://github.com/tvheadend/tvheadend/blob/master/src/webui/static/img/logomid.png)][appurl]

Tvheadend is a TV streaming server and recorder for Linux, FreeBSD and Android supporting DVB-S, DVB-S2, DVB-C, DVB-T, ATSC, ISDB-T, IPTV, SAT>IP and HDHomeRun as input sources.
Multiple EPG sources are supported (over-the-air DVB and ATSC including OpenTV DVB extensions, XMLTV, PyXML). Visit (Tvheadend)[appurl] for more info.

## Quick Start

```
docker create \
  --name=Tvheadend \
  --net=bridge \
  -v <path to config>:/config \
  -v <path to epg>:/epg \
  -v <path to recordings>:/recordings \
  -p 9981:9981 \
  -p 9982:9982 \
  --device=/dev/dvb
  jplorg/tvheadend
```
The --device=/dev/dvb is only needed if you want to pass through a DVB card to the container. If you use IPTV or HDHomeRun you can leave it out.

You can choose between ,using tags, latest (default, and no tag required or a specific release branch of tvheadend. Add one of the tags, if required, to the jplorg/tvheadend line of the run/create command in the following format, jplorg/tvheadend:release-1.0

#### Tags

+ **latest** : latest release from official Tvheadend 4.2 branch.

## Donations
Please consider donating a cup of coffee for the developer through paypal using the button below.

[![Donate](https://www.dokuwiki.org/lib/exe/fetch.php?w=220&tok=95f428&media=https%3A%2F%2Fraw.githubusercontent.com%2Ftschinz%2Fdokuwiki_paypal_plugin%2Fmaster%2Flogo.jpg)](https://www.paypal.me/JPLORG/2,50EUR)

## Considerations

* The container is based on Debian, using the tvheadend debian package. For shell access whilst the container is running do `docker exec -it tvheadend /bin/bash`.
* The container will test whether the config file is available. If not it adds the arguments -C --noacl to the Tvheadend startup arguments.
* Currently the container has been tested using [iptvstack](https://iptvstack.com/) for IP TV. Due to the lack of possessing DVB cards these have not been tested.
* On Synology Docker (DSM 6 - kernel 3.10) for the first time (first run), using the Tvheadend wizard for configuration, the container freezes after about 2 - 4 hours without notification. The container runs without problems, even when run for the first time, using an existing configuration.
* The comskip installation has not been tested yet!
* Container local time is default set to Europe/Amsterdam. This can be changed using `-e TZ` (where TZ is eg Europe/Berlin).

## Usage

**Parameters**

The parameters are split into two halves, separated by a colon, the left hand side representing the host and the right the container side. 
For example with a port -p external:internal - what this shows is the port mapping from internal to external of the container.
So -p 8080:80 would expose port 80 from inside the container to be accessible from the host's IP on port 8080
http://172.12.x.x:8080 would show you what's running INSIDE the container on port 80.

* `-p 1234` - the port(s)
* `-v /config` - Where TVHeadend show store it's config files
* `-v /recordings` - Where you want the PVR to store recordings
* `-e PGID` for GroupID - see below for explanation
* `-e PUID` for UserID - see below for explanation
* `-e RUN_OPTS` additional runtime parameters - see below for explanation
* `--device=/dev/dvb` - for passing through DVB-cards
* `--net=host` - for IPTV, SAT>IP and HDHomeRun
* `-e TZ` - for timezone information *eg Europe/London, etc*

**User / Group Identifiers**

When using volumes (`-v` flags) permission issues arise between the host OS and the container. This can be avoided by specifying the user `PUID` and group `PGID`. 
Ensure the volumes directories on the host are read/writable by the container user. The container user is hts which is part of the groups video and users.

In this instance `PUID=103` and `PGID=44`. To find yours use `id user` as below:

```
  $ id <dockeruser>
    uid=103(dockeruser) gid=44(dockergroup) groups=44(dockergroup)
```
**EPG XML file**

If you have EPG data in XML format from a supplier, you can drop it in the epg folder of your volume mapping. If it doesn't exist, create it. Then choose the XML file grabber in Configuration --> Channel/EPG --> EPG Grabber Modules.
If you use WebGrab+Plus, choose the WebGrab+Plus XML file grabber. The XML file goes in the same path as above.
The xml file has to be named guide.xml.

For advanced setup of tvheadend, go to [Tvheadend][appurl]

**Configuring XMLTV grabber**

To configure a XMLTV grabber, first check if the grabber is listed in Configuration --> Channel/EPG --> EPG Grabber Modules. If it's listed, configure the grabber before enabling.
The WebGrab+Plus grabber is available in /usr/bin/tvgrab++. Use /epg as the location of guide.xml.

**Comskip**
This container comes with Comskip for commercial flagging of recordings. This can be added in the recording config of tvheadend.
Go to Configuration --> Recording. Change the view level to advanced in the top right corner, and add the below in the Post-processor command field.

```
/usr/bin/comskip --ini=/config/comskip/comskip.ini "%f"
```

Now comskip will run after each recording is finished. The comskip.ini in located in the comskip folder of the /config volume mapping. See the [Comskip](http://www.kaashoek.com/comskip/) homepage for tuning of the ini file.

**FFmpeg**

FFmpeg is installed in /usr/bin/ in case it is needed.

## Info

* Shell access whilst the container is running: `docker exec -it tvheadend /bin/bash`
* To monitor the logs of the container in realtime: `docker logs -f tvheadend`

* container version number 

`docker inspect -f '{{ index .Config.Labels "build_version" }}' tvheadend`

* image version number

`docker inspect -f '{{ index .Config.Labels "build_version" }}' jplorg/tvheadend`


## Versions

+ **xx.xx.xx:** Initial release.

## Changelog

Please refer to: [CHANGELOG.md](CHANGELOG.md)
