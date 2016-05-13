#!/bin/bash

TS=$1

BASE=$(basename $TS .ts)
[ "${BASE}.ts" = "$(basename $TS)" ] || exit 1

CPU_CORES=$(/usr/bin/getconf _NPROCESSORS_ONLN)

X264_HIGH_HDTV="-f mp4 -vcodec libx264 \
    -fpre /opt/encode2/libx264-hq-ts.ffpreset \
    -r 30000/1001 -aspect 16:9 -s 1280x720 -bufsize 20000k -maxrate 25000k \
    -acodec libfdk_aac -ac 2 -ar 48000 -ab 128k -vsync 1 -threads ${CPU_CORES}"

/usr/local/bin/ffmpeg -y -loglevel quiet -i $TS ${X264_HIGH_HDTV} /hdd2/owncloud/astel/files/tv2/${BASE}.mp4

exit
