# !/bin/sh
# for UBUNTU linux jumper deployment
# required: before excuted,please use sudo su to switch to root user for free of sudo operations!


# chilid function
cpJumperResources () {
  su $1 -s "/bin/bash" -c "mkdir -p ~/.config/openbox"
  cp -f ~/jumper/gfreerdp ~/jumper/menu.xml  /home/$1/.config/openbox/
  echo "wish ~/.config/openbox/gfreerdp" > /home/$1/.config/openbox/autostart.sh
  chmod +x /home/$1/.config/openbox/autostart.sh  /home/$1/.config/openbox/gfreerdp
  # restrict the common user privileges
  chown root /home/$1/.bashrc /home/$1/.profile
}

# resolve links - $0 may be a softlink
PRG="$0"

while [ -h "$PRG" ]; do
  ls=`ls -ld "$PRG"`
  link=`expr "$ls" : '.*-> \(.*\)$'`
  if expr "$link" : '/.*' > /dev/null; then
    PRG="$link"
  else
    PRG=`dirname "$PRG"`/"$link"
  fi
done

# Get standard environment variables
PRGDIR=`dirname "PRG"`

# user must be root!
usertest=`whoami`

if [ $usertest != "root" ];then
  echo "you must use root to run this script!use 'sudo su' to switch to root user!"
  exit 1
fi

# offline debs site
OFFLINE_DEBS_SITE="http://192.168.31.133"
OFFLINE_DEBS_JUMPER_URL="$OFFLINE_DEBS_SITE/jumper"

mkdir -p ~/jumper
cd ~/jumper


echo "get ubuntu jumper resources..."
curl -O $OFFLINE_DEBS_JUMPER_URL/gfreerdp -O $OFFLINE_DEBS_JUMPER_URL/menu.xml -O $OFFLINE_DEBS_JUMPER_URL/sources.list -O $OFFLINE_DEBS_JUMPER_URL/jumper-public-key.sec

echo "set vi keyboard setting..."
echo "set nocompatible" >> /etc/vim/vimrc.tiny
echo "set backspace=2" >> /etc/vim/vimrc.tiny

echo "set timezone..."
timedatectl set-timezone "Asia/Shanghai"

echo "use local offline debs site..."
mv /etc/apt/sources.list /etc/apt/sources.list.bak
echo "deb $OFFLINE_DEBS_SITE/jumper debs/" > /etc/apt/sources.list


echo "import deb release key..."
apt-key add ~/jumper/jumper-public-key.sec
apt-get update


echo "install from local offline site..."
apt-get install -y xrdp xorg openbox wish freerdp-x11 ntpdate zip unzip numlockx

echo "modify default remote desktop config..."
sed -i "/^MaxSessions=/cMaxSessions=250" /etc/xrdp/sesman.ini
sed -i "/^DisconnectedTimeLimit=/cDisconnectedTimeLimit=60" /etc/xrdp/sesman.ini
sed -i "/^Policy=/cPolicy=UBC" /etc/xrdp/sesman.ini


delete_line_begin=`sed -n '/\[X11rdp\]/=' /etc/xrdp/xrdp.ini`

sed -i "$delete_line_begin,\$d" /etc/xrdp/xrdp.ini
sed -i "/^username=/cusername=askjumper" /etc/xrdp/xrdp.ini
sed -i "/^password=/cpassword=askjumper" /etc/xrdp/xrdp.ini


echo "add remote desktop user,you should input jumper as default password..."
adduser jumper --shell /usr/sbin/nologin

echo "add openbox desktop config..."
if [ -r /home/jumper/ ];then
  echo "add openbox desktop to common jumper user..."
  cpJumperResources jumper
fi

echo "use special system mirror..."
cp -f ~/jumper/sources.list /etc/apt/sources.list
# replace the favourite mirror
sed -i 's/mirrors.aliyun.com/mirrors.ustc.edu.cn/' /etc/apt/sources.list

