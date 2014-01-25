#################### Mastering OpenStack Controller Install ####################

export PUBLIC_IP=192.168.79.50
export INTERNAL_IP=10.10.100.50

# MySQL install preparation
export DEBIAN_FRONTEND=noninteractive
export MYSQL_ROOT_PASS=openstack
export MYSQL_HOST=0.0.0.0
export MYSQL_PASS=openstack

echo "mysql-server-5.5 mysql-server/root_password password $MYSQL_ROOT_PASS" | sudo debconf-set-selections
echo "mysql-server-5.5 mysql-server/root_password_again password $MYSQL_ROOT_PASS" | sudo debconf-set-selections
echo "mysql-server-5.5 mysql-server/root_password seen true" | sudo debconf-set-selections
echo "mysql-server-5.5 mysql-server/root_password_again seen true" | sudo debconf-set-selections
        
sudo apt-get update
sudo apt-get install -y ubuntu-cloud-keyring vim git ntp openssh-server curl
sudo echo "deb http://ubuntu-cloud.archive.canonical.com/ubuntu precise-updates/havana main" | sudo tee /etc/apt/sources.list.d/havana.list
sudo apt-get install python-software-properties -y
sudo apt-get update && apt-get upgrade -y

rm /etc/hosts

echo "127.0.0.1 localhost
${INTERNAL_IP} aio-havana
" > /etc/hosts

# Install NTP while we are here
echo "ntpdate controller
hwclock -w" | sudo tee /etc/cron.daily/ntpdate
chmod a+x /etc/cron.daily/ntpdate

sudo apt-get -y install mysql-server python-mysqldb rabbitmq-server

sudo sed -i "s/^bind\-address.*/bind-address = ${MYSQL_HOST}/g" /etc/mysql/my.cnf

# Skip Name Resolve
echo "[mysqld]
skip-name-resolve" > /etc/mysql/conf.d/skip-name-resolve.cnf

sudo restart mysql

