#!/bin/sh

sudo virt-install --name rhel8-ks \
--memory 2048 \
--vcpus 1 \
--location /storage/ISO/rhel-8.6-x86_64-dvd.iso \
--initrd-inject $(pwd)/rhel8-ks.cfg \
--os-variant=rhel8-unknown \
--console pty,target_type=serial \
--extra-args "ks=file:/rhel8-ks.cfg console=tty0 console=ttyS0,115200n8" \
--disk size=60,pool=default,sparse=yes \
--network network=default --noautoconsole

