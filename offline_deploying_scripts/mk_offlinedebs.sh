# !/bin/sh
# required: before excuted,please use sudo su to switch to root user!
# required: curl && gpg shell scripts

echo "use key sign..."

if [ ! -r jumper-private-key.sec ] ; then
   echo "get private key from deploying server..."
   OFFLINE_DEBS_SITE="http://192.168.31.133/"
   OFFLINE_DEBS_JUMPER_URL="$OFFLINE_DEBS_SITE/jumper"
   curl -O $OFFLINE_DEBS_JUMPER_URL/jumper-private-key.sec
fi

gpg --import jumper-private-key.sec

echo "get the needed deb resources of jumper..."

# maybe mirror changed,so update firstly to reform indexs 
apt-get update

apt-get install -y xrdp xorg openbox wish freerdp-x11 ntpdate zip unzip numlockx

rm -rf /var/debs

if [ -r /var/debs.tar ] ; then 
   yes | rm -f /var/debs.tar
fi

mkdir -p /var/debs
cp -r /var/cache/apt/archives/*.deb /var/debs/

echo "to form debs index file..."
cd /var/

apt-ftparchive packages debs > debs/Packages
cd debs
gzip -c Packages > Packages.gz
apt-ftparchive release . > Release


gpg --local-user jumper --clearsign -o InRelease Release
gpg --local-user jumper -abs -o Release.gpg Release


echo "create debs tar file at /var/debs.tar ..."
cd /var/
tar cvf debs.tar debs/

echo "create debs tar file at /var/debs.tar end..."
