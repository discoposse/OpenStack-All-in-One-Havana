## CINDER INSTALL - requires that you have added your virtual hard disk

export MYSQL_ROOT_PASS=openstack
export MYSQL_HOST=localhost
export MYSQL_PASS=openstack

source /root/openrc

mysql -h localhost -uroot -p$MYSQL_ROOT_PASS -e "CREATE DATABASE cinder;"
mysql -h localhost -uroot -p$MYSQL_ROOT_PASS -e "GRANT ALL ON cinder.* TO 'cinder'@'localhost' IDENTIFIED BY '$MYSQL_PASS';"
mysql -h localhost -uroot -p$MYSQL_ROOT_PASS -e "GRANT ALL ON keystone.* TO 'cinder'@'%' IDENTIFIED BY '$MYSQL_PASS';"

sudo apt-get install -y cinder-api cinder-scheduler

# Configure Cinder for our MySQL database
sudo sed -i 's#^connection.*#connection = mysql://cinder:openstack@127.0.0.1/cinder#' /etc/cinder/cinder.conf

sudo cinder-manager db sync

TENANT_ID=$(keystone tenant-list | awk '/\ admin\ / {print $2}')
ROLE_ID=$(keystone role-list | awk '/\ admin\ / {print $2}')
ADMIN_ROLE_ID=$(keystone role-list | awk '/\ admin\ / {print $2}')
USER_ID=$(keystone user-list | awk '/\ admin\ / {print $2}')
SERVICE_TENANT_ID=$(keystone tenant-list | awk '/\ service\ / {print $2}')

# Cinder Block Storage Service
CINDER_SERVICE_ID=$(keystone service-list | awk '/\ volume\ / {print $2}')

PUBLIC="http://$ENDPOINT:8776/v1/%(tenant_id)s"
ADMIN=$PUBLIC
INTERNAL=$PUBLIC

keystone user-create --name cinder --pass cinder --tenant_id $SERVICE_TENANT_ID --email cinder@localhost --enabled true

sudo sed -i 's#^sql_connection.*#sql_connection = mysql://cinder:openstack@127.0.0.1/cinder#' /etc/cinder/api-paste.ini
sudo sed -i 's#^auth_host.*#auth_host = aio-havana#' /etc/cinder/api-paste.ini
sudo sed -i 's#^admin_tenant_name.*#admin_tenant_name = service#' /etc/cinder/api-paste.ini
sudo sed -i 's#^admin_user.*#admin_user = cinder#' /etc/cinder/api-paste.ini
sudo sed -i 's#^admin_password.*#admin_password = cinder#' /etc/cinder/api-paste.ini

# Cinder Block Storage Endpoint
keystone service-create --name volume --type volume --description 'Volume Service'

# Get the cinder user id
CINDER_USER_ID=$(keystone user-list | awk '/\ cinder \ / {print $2}')

CINDER_SERVICE_ID=$(keystone service-list | awk '/\ volume\ / {print $2}')

# Assign the cinder user the admin role in service tenant
keystone user-role-add --user $CINDER_USER_ID --role $ADMIN_ROLE_ID --tenant_id $SERVICE_TENANT_ID

keystone endpoint-create --region RegionOne --service_id $CINDER_SERVICE_ID --publicurl $PUBLIC --adminurl $ADMIN --internalurl $INTERNAL

PUBLIC="http://$ENDPOINT:8776/v2/%(tenant_id)s"
ADMIN=$PUBLIC
INTERNAL=$PUBLIC

# Cinder Block Storage Endpoint V2
keystone service-create --name volume --type volumev2 --description 'Volume Service V2'

CINDER_SERVICE_ID=$(keystone service-list | awk '/\ volumev2\ / {print $2}')

keystone endpoint-create --region RegionOne --service_id $CINDER_SERVICE_ID --publicurl $PUBLIC --adminurl $ADMIN --internalurl $INTERNAL

echo "
rpc_backend = cinder.openstack.common.rpc.impl_kombu
rabbit_host = aio-havana
rabbit_port = 5672
" | sudo tee /etc/cinder/cinder.conf

sudo sed -i 's#filter*#filter = [ "a/sdb/" ]#' /etc/lvm/lvm.conf

sudo service cinder-volume restart
sudo service tgt restart
