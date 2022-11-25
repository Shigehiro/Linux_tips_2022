#!/bin/sh

sudo virt-install --name rocky87-ks \
--memory 2048 \
--vcpus 1 \
--location /storage/ISO/Rocky-8.7-x86_64-dvd1.iso \
--initrd-inject $(pwd)/rocky87_ks.cfg \
--os-variant=rocky8.6 \
--console pty,target_type=serial \
--extra-args "ks=file:/rocky87_ks.cfg console=tty0 console=ttyS0,115200n8" \
--disk size=60,pool=default,sparse=yes \
--network network=default --noautoconsole

