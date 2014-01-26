OpenStack-All-in-One-Havana
===========================

OpenStack Havana All-in-One install

These scripts are to go along with my blog post for deployment of an OpenStack Havana All-in-One node on Ubuntu 12.04 LTS running as a guest on VMware Workstation.

The scripts require some input including two system variables:

INTERNAL_IP
INTERNAL_GW

Full instructions on how to use these scripts is located here:


The All-in-One node includes:
- Keystone
- Glance (with CirrOS 0.3.1 image downloaded)
- Nova (KVM)
- Horizon 

Additianal scripts will be added for deploying further components.

