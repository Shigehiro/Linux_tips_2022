# Build a custom RHEL8 image for KVM

Here is how to make a RHEL8 custom image for KVM.
Similar way to [custom image build for Rocky8](https://github.com/Shigehiro/Linux_tips_2022/blob/master/Rocky8_create_custom_qcow2_image/README.md)

# walkthrough log

build image
```
$ sh build_rhel8_legacy_bios.sh
```

get the qcow2 and undefine the vm.
```
$ virsh domblklist rhel8-ks 
 Target   Source
----------------------------------------------
 vda      /storage/kvm_images/rhel8-ks.qcow2
 sda      -
```

```
$ sudo mv /storage/kvm_images/rhel8-ks.qcow2 ./
```

```
$ sudo virsh undefine rhel8-ks --remove-all-storage 
```

then run virt-sparsify and virt-sysprep
```
$ sudo virt-sparsify --compress ./rhel8-ks.qcow2 rhel86-template.qcow2
```

```
$ sudo virt-sysprep -a rhel86-template.qcow2
```