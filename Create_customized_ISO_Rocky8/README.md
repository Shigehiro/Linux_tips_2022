# 1. RockyLinux8.6: How to embed a kickstart in a RockyLinux 8 ISO 

- [1. RockyLinux8.6: How to embed a kickstart in a RockyLinux 8 ISO](#1-rockylinux86-how-to-embed-a-kickstart-in-a-rockylinux-8-iso)
- [2. Description](#2-description)
- [3. Reference](#3-reference)
- [4. Test Conditions](#4-test-conditions)
- [5. Walkthrough logs](#5-walkthrough-logs)
  - [5.1. Install RockyLinux manually from an original ISO](#51-install-rockylinux-manually-from-an-original-iso)
  - [5.2. Make the customized ISO](#52-make-the-customized-iso)
  - [5.3. Install RockyLinux with the customized ISO](#53-install-rockylinux-with-the-customized-iso)
- [6. Error when making an ISO](#6-error-when-making-an-iso)

# 2. Description

Here is how to put a kickstart file in an ISO image.

# 3. Reference

- https://access.redhat.com/solutions/60959
- https://access.redhat.com/documentation/en-us/red_hat_enterprise_linux/8/html/performing_an_advanced_rhel_8_installation/kickstart-installation-basics_installing-rhel-as-an-experienced-user
- https://unix.stackexchange.com/questions/641277/centos-8-custom-iso-adding-ks-cdrom-ks-cfg-hangs-the-installer

# 4. Test Conditions

- Tested under KVM
- RockyLinux VM
  - UEFI boot
  - 4 vNICs(virtio)
  - 60GB vHDD(virtio)
- KVM host is Ubuntu 22.04
  - install RockyLinux VM under KVM(Ubuntu 22.04)
- make a custom ISO on Ubuntu 22.04

# 5. Walkthrough logs

## 5.1. Install RockyLinux manually from an original ISO

At first, intall RockyLinux manually by using the original ISO.
- UEFI boot, 4 vNICs, 60GB virtual disk

Here is a kickstart file after installing RockyLinux manually.
Use this file for the testing.

access to the VM.
You can find the kickstart file at /root/anaconda-ks.cfg
```text
#version=RHEL8
# Use graphical install
graphical

repo --name="AppStream" --baseurl=file:///run/install/sources/mount-0000-cdrom/AppStream

%packages
@^server-product-environment
@debugging
@hardware-monitoring
@headless-management
@performance
@security-tools
@system-tools
kexec-tools

%end

# Keyboard layouts
keyboard --xlayouts='jp'
# System language
lang en_US.UTF-8

# Network information
network  --bootproto=static --device=enp1s0 --gateway=172.16.0.1 --ip=172.16.0.51 --nameserver=8.8.8.8,8.8.4.4 --netmask=255.255.255.0 --ipv6=auto --activate
network  --bootproto=dhcp --device=enp2s0 --onboot=off --activate
network  --bootproto=dhcp --device=enp3s0 --onboot=off --activate
network  --bootproto=dhcp --device=enp4s0 --onboot=off --activate
network  --bootproto=dhcp --device=enp5s0 --onboot=off --activate
network  --hostname=localhost.localdomain

# Use CDROM installation media
cdrom

# Run the Setup Agent on first boot
firstboot --enable

ignoredisk --only-use=vda
# Partition clearing information
clearpart --none --initlabel
# Disk partitioning information
part /boot/efi --fstype="efi" --ondisk=vda --size=600 --fsoptions="umask=0077,shortname=winnt"
part /boot --fstype="xfs" --ondisk=vda --size=1024
part pv.116 --fstype="lvmpv" --ondisk=vda --size=59814
volgroup rl --pesize=4096 pv.116
logvol swap --fstype="swap" --size=2079 --name=swap --vgname=rl
logvol / --fstype="xfs" --size=57727 --name=root --vgname=rl

# System timezone
timezone Asia/Tokyo --isUtc

# Root password
rootpw --iscrypted $6$JrYYwyFdKakAfgS3$me7J90ZyBjtxlQb70UhvHW7SDqsEgEbCTtfirlMVFDa0zTl734hGo.IRW9n1kJe7R1N5NP8DiGCBghfy55dL..
user --groups=wheel --name=hattori --password=$6$OcR0Xp.m5VFHw224$5nK1NEemO8SDllDOzqHrxIXnSgGnwndYHFAZxbS3JTFbi0A4Qi5EIru87NTWlJlzmlpPO/ylLbxtqLPZVkMCa. --iscrypted --gecos="hattori"

%addon com_redhat_kdump --enable --reserve-mb='auto'

%end

%anaconda
pwpolicy root --minlen=6 --minquality=1 --notstrict --nochanges --notempty
pwpolicy user --minlen=6 --minquality=1 --notstrict --nochanges --emptyok
pwpolicy luks --minlen=6 --minquality=1 --notstrict --nochanges --notempty
%end
```

## 5.2. Make the customized ISO

On Ubuntu host, install required packages.
```text
$ tail -1 /etc/lsb-release 
DISTRIB_DESCRIPTION="Ubuntu 22.04.1 LTS"

$ qemu-system-x86_64 -version
QEMU emulator version 6.2.0 (Debian 1:6.2+dfsg-2ubuntu6.3)
Copyright (c) 2003-2021 Fabrice Bellard and the QEMU Project developers

$ sudo apt install genisoimage syslinux-utils isomd5sum -y
```

mount the ISO.
error.
```text
$ mkdir mnt
$ mount -o loop ./Rocky-8.6-x86_64-dvd1.iso ./mnt/
mount: ./mnt/: failed to setup loop device for /home/hattori/Kickstart_ISO/Rocky-8.6-x86_64-dvd1.iso.
```

need to run with sudo.
```text
$ sudo mount -o loop ./Rocky-8.6-x86_64-dvd1.iso ./mnt/
mount: /home/hattori/Kickstart_ISO/mnt: WARNING: source write-protected, mounted read-only.
```

copy all files to a working directory.
```text
$ mkdir rl8
$ shopt -s dotglob
$ cp -avRf ./mnt/* rl8/
```

How to generate encrypted password.
- https://access.redhat.com/solutions/221403
```text
$ python3 -c 'import crypt,getpass; print(crypt.crypt(getpass.getpass()))'
Password: 
```

put the kickstart file.
```text
$ cp ks.cfg rl8/

$ blkid Rocky-8.6-x86_64-dvd1.iso 
Rocky-8.6-x86_64-dvd1.iso: BLOCK_SIZE="2048" UUID="2022-05-15-21-06-44-00" LABEL="Rocky-8-6-x86_64-dvd" TYPE="iso9660" PTUUID="6b8b4567" PTTYPE="dos"
```

add the following lines in isolinux.cfg
```text
$ grep custom -A5 rl8/isolinux/isolinux.cfg 
### custom
label kickstart
  menu label ^Kickstart Install Rocky Linux 8
  kernel vmlinuz
  append initrd=initrd.img inst.stage2=hd:LABEL=Rocky-8-6-x86_64-dvd inst.ks=cdrom:/ks.cfg
###
```

edit grub.cfg. add `inst.ks..`
```text
$ grep 10_linux -A3 rl8/EFI/BOOT/grub.cfg 
### BEGIN /etc/grub.d/10_linux ###
menuentry 'Install Rocky Linux 8' --class fedora --class gnu-linux --class gnu --class os {
	linuxefi /images/pxeboot/vmlinuz inst.stage2=hd:LABEL=Rocky-8-6-x86_64-dvd inst.ks=cdrom:/ks.cfg
	initrdefi /images/pxeboot/initrd.img
```

make the ISO.
```text
$ cd rl8

$ sudo mkisofs -o ~/rl8_test.iso -b isolinux/isolinux.bin -J -R -l -c isolinux/boot.cat -no-emul-boot -boot-load-size 4 -boot-info-table -eltorito-alt-boot -e images/efiboot.img -no-emul-boot -graft-points -V "Rocky-8-6-x86_64-dvd" .

$ sudo isohybrid --uefi ~/rl8_test.iso

$ sudo implantisomd5 ~/rl8_test.iso
```

## 5.3. Install RockyLinux with the customized ISO

Prepare the same hardware spec VM(vNICs, Disk size, UEFI boot) and install RockyLinux VM with the customized ISO.
After booting from the ISO, select `Install Rocky Linux 8` on the instllation menu.
The instllation will automatically start.

# 6. Error when making an ISO

If you see an error as below when making an ISO, try adding `-joliet-long `

```text
$ sudo mkisofs -o ~/rl8_test.iso -b isolinux/isolinux.bin -U -J -R -l -c isolinux/boot.cat -no-emul-boot -boot-load-size 4 -boot-info-table -eltorito-alt-boot -e images/efiboot.img -no-emul-boot -graft-points -V "RHEL-8-6-0-BaseOS-x86_64" .

genisoimage: Error: ./AppStream/Packages/clang-resource-filesystem-13.0.1-1.module+el8.6.0+14118+d530a951.i686.rpm and ./AppStream/Packages/clang-resource-filesystem-13.0.1-1.module+el8.6.0+14118+d530a951.x86_64.rpm have the same Joliet name
Joliet tree sort failed. The -joliet-long switch may help you.
```

```text
$ sudo mkisofs -o ~/rl8_test.iso -b isolinux/isolinux.bin -joliet-long -J -R -l -c isolinux/boot.cat -no-emul-boot -boot-load-size 4 -boot-info-table -eltorito-alt-boot -e images/efiboot.img -no-emul-boot -graft-points -V "RHEL-8-6-0-BaseOS-x86_64" .
```