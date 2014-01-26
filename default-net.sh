# Add our network
nova network-create vmnet --fixed-range-v4=10.10.100.0/24 --bridge-interface=br100 --multi-host=T

# Add our firewall rules to reach our instances over ICMP and SSH
nova secgroup-add-rule default tcp 22 22 0.0.0.0/0
nova secgroup-add-rule default icmp -1 -1 0.0.0.0/0


