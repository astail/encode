#!/bin/sh

encode_dir=/opt/encode2
video_dir=/hdd1/pt3/videouna
dest_dir=/hdd2/owncloud/astel/files/tv2
encode_list=/opt/encode2/encode.list

_lockfile="/tmp/`basename $0`.lock"
ln -s /dummy $_lockfile 2> /dev/null || { exit 9; }
trap "rm $_lockfile; exit" 1 2 3 15



echo ""
echo `date` "========== encode batch start =========="

app="recpt1"
if [ "" = "`pgrep -fo $app`" ]; then
  echo `date` "$appが動いていないので処理します。"
else
  echo `date` "$appが動いているため処理しません。"
  echo `date` "========== encode batch stop =========="
  rm $_lockfile
  exit 1
fi

echo `date` "encode video check now ..."
hoge=(`ls $video_dir | grep \\\.ts$`)
i=`expr ${#hoge[@]}`
while [ $i != 0 ]; do
  i=`expr $i - 1`
  name=${hoge[$i]}

  cat ${encode_list} | while read line; do
    if [ `echo "$name" | grep "$line"` ] ; then
      db=(`MYSQL_PWD="encode" mysql -N -B -u encoder encode2 -e "select name from encode WHERE name = '$name';" | wc -l`)
      if [ $db == 0 ]; then
        echo `date` "$nameをエンコードします。"
        $encode_dir/tsmp4.sh $video_dir/$name > /dev/null
        MYSQL_PWD="encode" mysql -N -B -u encoder encode2 -e "insert into encode (name,date) values('$name',now());"
        chown -R nginx:nginx $dest_dir
        echo `date` "encode end."
        sleep 2s
      fi
    fi
  done
done

echo `date` "all encode end"
echo `date` "========== encode batch stop =========="

rm $_lockfile
