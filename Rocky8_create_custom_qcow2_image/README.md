# 1. Creaate a custom template image(qcow2) for KVM

- [1. Creaate a custom template image(qcow2) for KVM](#1-creaate-a-custom-template-imageqcow2-for-kvm)
- [2. Description](#2-description)
- [3. Reference](#3-reference)
- [4. Environment](#4-environment)
- [5. Walkthrough](#5-walkthrough)

# 2. Description

Here is how to create a custom template image for KVM.

# 3. Reference

- https://www.getpagespeed.com/solutions/how-to-create-rocky-linux-8-image-which-supports-uefi-and-legacy-bios-mode-both
- https://access.redhat.com/labs/kickstartconfig/
- https://computingforgeeks.com/generate-rocky-linux-qcow2-image-for-openstack-kvm-qemu/
- https://dev.to/mediocredevops/creating-a-compressed-and-minimal-kvm-template-2pk9

# 4. Environment

- Host OS : Ubuntu 22.04
- VM : Rocky Linux 8.7

# 5. Walkthrough

Prepeare an Rocky ISO, a kickstart file. (see rocky87_ks.cfg )
The following url would be helpful as well.
- https://git.rockylinux.org/rocky/kickstarts/-/tree/r8

Biuld an image with virt-install ( build_rocky87_legacy_bios.sh )

As for `virt-install --os-variant <OS name>`, You can find supported OS by osinfo-query as below.
```text
$ sudo apt install -y libosinfo-bin

$ osinfo-query os |grep -i rocky
 rocky-unknown        | Rocky Linux Unknown                                | unknown  | http://rockylinux.org/rocky/unknown     
 rocky8-unknown       | Rocky Linux 8 Unknown                              | 8-unknown | http://rockylinux.org/rocky/8-unknown   
 rocky8.4             | Rocky Linux 8.4                                    | 8.4      | http://rockylinux.org/rocky/8.4         
 rocky8.5             | Rocky Linux 8.5                                    | 8.5      | http://rockylinux.org/rocky/8.5         
 rocky8.6             | Rocky Linux 8.6                                    | 8.6      | http://rockylinux.org/rocky/8.6         
 rocky9-unknown       | Rocky Linux 9 Unknown                              | 9-unknown | http://rockylinux.org/rocky/9-unknown   
 rocky9.0             | Rocky Linux 9.0                                    | 9.0      | http://rockylinux.org/rocky/9.0 
```

build an image
```text
$ sh build_rocky87_legacy_bios.sh      
```

uundefine the VM and make a template image by virt-sparsify and virt-sysprep.
```text
$ virsh domblklist rocky87-ks
 Target   Source
------------------------------------------------
 vda      /storage/kvm_images/rocky87-ks.qcow2
 sda      -

$ virsh undefine rocky87-ks
Domain 'rocky87-ks' has been undefined

$ sudo mv /storage/kvm_images/rocky87-ks.qcow2 .

$ sudo virt-sparsify --compress rocky87-ks.qcow2 rocky87-template.qcow2

$ ls -lh *.qcow2
-rw------- 1 root root  61G Nov 25 12:04 rocky87-ks.qcow2
-rw-r--r-- 1 root root 779M Nov 25 12:20 rocky87-template.qcow2

$ sudo virt-sysprep -a rocky87-template.qcow2
```

Finally confirm you can launch a VM with this image.