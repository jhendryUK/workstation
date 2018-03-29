#!/usr/bin/env bash

if [ $UID -ne 0 ]; then
    sudo "$0" $@
    exit 0
fi

cd $(realpath `dirname $0`/..)

./os/pkgs

# Prevent system from using dnsmasq or systemd-resolved for DNS
# Ubuntu 16.04 LTS
#sed -i -e '/dns=/d' /etc/NetworkManager/NetworkManager.conf
# Ubuntu 18.04 LTS
sed -i -e 's/dns=.*/dns=default/g' /etc/NetworkManager/NetworkManager.conf
systemctl  disable systemd-resolved.service
service sttemd-resolved stop

# disable stupid default daemons
for i in avahi-daemon avahi-dnsconfd apparmor cups cups-browsed saned; do
    update-rc.d -f $i remove
done

# Stop popularity contest from working
popcon=/etc/cron.daily/popularity-contest
if [ -e "$popcon" ]; then
    mv $popcon ${popcon}.dist
fi

# Prepare sudo for udiskie
echo "ALL   ALL=NOPASSWD: /usr/bin/udiskie -s -F" > /etc/sudoers.d/udiskie

cp -fv ./i3blocks/i3blocks.conf /etc/i3blocks.conf
