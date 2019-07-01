#!/bin/sh -e
#
# Auto-generated BIND files will temporarily be put here
if [ ! -d "gen4bind" ]; then
  mkdir gen4bind
fi	
#
# Generate a secure key that will be used by the DNS
if [ ! -f Kcloud.ddns.filename ]; then
  dnssec-keygen -r /dev/urandom -a HMAC-MD5 -b 512 -n HOST cloud.ddns > Kcloud.ddns.filename
fi
#
# create bind server zone files and resolv.conf
python gen_bind_files.py
#
# create ddns.sh
python gen_ddns_sh.py
chmod +x ddns.sh
#
# copy generated files to the right directories
cp /etc/bind/named.conf.local /etc/bind/named.conf.local.ori
mv gen4bind/named.*.conf /etc/bind/
mv gen4bind/forward.cloudzone /var/lib/bind/
mv gen4bind/reverse.cloudzone.* /var/lib/bind/
#cp /etc/resolv.conf /etc/resolv.conf.ori
#mv gen4bind/resolv.conf /etc/resolv.conf
#
# check presence of /var/lib/bind/
if [ ! -d "/var/lib/bind" ]; then
  mkdir /var/lib/bind
  chown -R bind:bind /var/lib/bind
  chmod -R 775 /var/lib/bind
fi
#
# restart DNS
systemctl restart bind9
#
# edit ifcfg-eth0 to prevent resolv.conf from being overwritten
#echo "PEERDNS=no" >> /etc/sysconfig/network-scripts/ifcfg-eth0
