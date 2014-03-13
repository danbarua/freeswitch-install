#!/bin/bash

# FreeSWITCH Install Script for Ubuntu 12.04LTS and above

#
# cribbed from https://gist.github.com/sagmor/6470996
# and https://github.com/plivo/plivoframework/blob/master/freeswitch/install.sh
#


FS_INSTALL_REPO=https://raw.github.com/danbarua/freeswitch-install/master
FS_GIT_REPO=git://git.freeswitch.org/freeswitch.git
FS_INSTALLED_PATH=/usr/local/freeswitch
FS_BASE_PATH=/usr/local/src

CURRENT_PATH=$PWD

echo ""
echo "FreeSWITCH will be installed in $FS_INSTALLED_PATH"

apt-get -y update
apt-get -y install autoconf automake autotools-dev binutils bison build-essential cpp curl flex g++ gcc git-core libaudiofile-dev libc6-dev libdb-dev libexpat1 libgdbm-dev libgnutls-dev libmcrypt-dev libncurses5-dev libnewt-dev libpcre3 libpopt-dev libsctp-dev libsqlite3-dev libtiff4 libtiff4-dev libtool libx11-dev libxml2 libxml2-dev lksctp-tools lynx m4 make mcrypt ncftp nmap openssl sox sqlite3 ssl-cert ssl-cert unixodbc-dev unzip zip zlib1g-dev zlib1g-dev libjpeg-dev libssl-dev sox

cd $FS_BASE_PATH
git clone $FS_GIT_REPO
cd $FS_BASE_PATH/freeswitch
sh bootstrap.sh && ./configure --prefix=$FS_INSTALLED_PATH
[ -f modules.conf ] && cp modules.conf modules.conf.bak

sed -i \
-e "s/#applications\/mod_curl/applications\/mod_curl/g" \
-e "s/#asr_tts\/mod_flite/asr_tts\/mod_flite/g" \
-e "s/#asr_tts\/mod_pocketsphinx/asr_tts\/mod_pocketsphinx/g" \
-e "s/#asr_tts\/mod_tts_commandline/asr_tts\/mod_tts_commandline/g" \
-e "s/#formats\/mod_shout/formats\/mod_shout/g" \
-e "s/#endpoints\/mod_dingaling/endpoints\/mod_dingaling/g" \
-e "s/#formats\/mod_shell_stream/formats\/mod_shell_stream/g" \
-e "s/#applications\/mod_soundtouch/applications\/mod_soundtouch/g" \
-e "s/#say\/mod_say_de/say\/mod_say_de/g" \
-e "s/#say\/mod_say_es/say\/mod_say_es/g" \
-e "s/#say\/mod_say_fr/say\/mod_say_fr/g" \
-e "s/#say\/mod_say_it/say\/mod_say_it/g" \
-e "s/#say\/mod_say_nl/say\/mod_say_nl/g" \
-e "s/#say\/mod_say_ru/say\/mod_say_ru/g" \
-e "s/#say\/mod_say_zh/say\/mod_say_zh/g" \
-e "s/#say\/mod_say_hu/say\/mod_say_hu/g" \
-e "s/#say\/mod_say_th/say\/mod_say_th/g" \
modules.conf
make && make install && make sounds-install && make moh-install

# Enable FreeSWITCH modules
cd $FS_INSTALLED_PATH/conf/autoload_configs/
[ -f modules.conf.xml ] && cp modules.conf.xml modules.conf.xml.bak
sed -i -r \
-e "s/<\!--\s?<load module=\"mod_xml_curl\"\/>\s?-->/<load module=\"mod_xml_curl\"\/>/g" \
-e "s/<\!--\s?<load module=\"mod_xml_cdr\"\/>\s?-->/<load module=\"mod_xml_cdr\"\/>/g" \
-e "s/<\!--\s?<load module=\"mod_dingaling\"\/>\s?-->/<load module=\"mod_dingaling\"\/>/g" \
-e "s/<\!--\s?<load module=\"mod_shout\"\/>\s?-->/<load module=\"mod_shout\"\/>/g" \
-e "s/<\!--\s?<load module=\"mod_tts_commandline\"\/>\s?-->/<load module=\"mod_tts_commandline\"\/>/g" \
-e "s/<\!--\s?<load module=\"mod_flite\"\/>\s?-->/<load module=\"mod_flite\"\/>/g" \
-e "s/<\!--\s?<load module=\"mod_pocketsphinx\"\/>\s?-->/<load module=\"mod_pocketsphinx\"\/>/g" \
-e "s/<\!--\s?<load module=\"mod_soundtouch\"\/>\s?-->/<load module=\"mod_soundtouch\"\/>/g" \
-e "s/<\!--\s?<load module=\"mod_say_ru\"\/>\s?-->/<load module=\"mod_say_ru\"\/>/g" \
-e "s/<\!--\s?<load module=\"mod_say_zh\"\/>\s?-->/<load module=\"mod_say_zh\"\/>/g" \
-e 's/mod_say_zh.*$/&\n    <load module="mod_say_de"\/>\n    <load module="mod_say_es"\/>\n    <load module="mod_say_fr"\/>\n    <load module="mod_say_it"\/>\n    <load module="mod_say_nl"\/>\n    <load module="mod_say_hu"\/>\n    <load module="mod_say_th"\/>/' \
modules.conf.xml

#add freeswitch group if not exists
if ! getent group freeswitch >/dev/null; then
      groupadd --system freeswitch
fi

#add freeswitch user if not exists
if ! getent passwd freeswitch >/dev/null; then
  useradd --system -g freeswitch -G audio -g daemon \
    -d /usr/local/freeswitch \
    -c 'FreeSWITCH' \
    freeswitch
fi

for x in \
 	  $FS_INSTALLED_PATH \
      /var/run/freeswitch;
do
  mkdir -p $x
  chown -R freeswitch:freeswitch $x
  chmod -R o-rwx,g+u $x
done

#setup init.d
wget --no-check-certificate $FS_INSTALL_REPO/freeswitch.init -O /etc/init.d/freeswitch
chmod 755 /etc/init.d/freeswitch

#make init.d/freeswitch run at boot
update-rc.d -f freeswitch defaults
cp $FS_BASE_PATH/freeswitch/debian/freeswitch-sysvinit.freeswitch.default /etc/default/freeswitch

#create symlinks so you can run freeswitch anywhere in terminal
ln -s /usr/local/freeswitch/bin/fs_cli /usr/local/bin/
ln -s /usr/local/freeswitch/bin/freeswitch /usr/local/bin/freeswitch

#chmod freeswitch dir so you can cd to it
chmod 755 /usr/local/freeswitch

#start daemon
/etc/init.d/freeswitch start


cd $CURRENT_PATH
# Install Complete
#clear
echo ""
echo ""
echo ""
echo "**************************************************************"
echo "Congratulations, FreeSWITCH is now installed at '$FS_INSTALLED_PATH'"
echo "**************************************************************"
echo ""
echo ""
exit 0
