# Create Windows vWS with vGPU and Looking Glass

Create your Windows VM similarly to how we created Linux VM. In this example I created a VM with VMID `302`. You can also add the same optional devices, even serial since Windows also supports serial console in the form of Windows Emergency Management Services. What's not optional though, is that you need to add 2 `CD/DVD Drive`, with `virtio-win.iso` under IDE bus 0, and `lg-win.iso` under SATA bus 1. Settings here affect how Windows assigns drive letters, so if you are not following this setting, be careful later on when there is a path listed. Finally, add your vGPU here. Windows can support both Virtio-GPU and vGPU at the same time.

Now start VM and install Windows. When Windows Installer asks you `Where do you want to install Windows?`, click `Load driver`, and `Browse` `E:\amd64\w11` to install `Red Hat VirtIO SCSI pass-through controller`, **AND** `E:\NetKVM\w11\amd64\` to install `Red Hat VirtIO Ethernet Adapter`. Windows is moving towards more online services, and you have to use an online account in Home edition. Pro edition is *currently* unaffected, but let's install the network driver just in case.

During OOBE setup you can create account **without password** so you don't have to click through 3 password recovery questions. After OOBE is done, go to `Settings` and enable RDP, add password (required for RDP login).

You now need to install VirtIO drivers with everything selected (`E:\virtio-win-guest-tools.exe`), NVIDIA driver, [IVSHMEM driver](https://looking-glass.io/docs/B5.0.1/install/#installing-the-ivshmem-driver) under `Win10\amd64` folder (**make sure it reads `IVSHMEM Device` in `Device Manager`**, not `PCI standard RAM Controller`), and Looking Glass, which all located under `D:\`. Go to `Services` and make sure `Looking Glass (host)` service is `Running`, and you have completed the Windows VM setup. After drivers are installed, disable sleep (will mess up IVSHMEM file on Proxmox), and shut down Windows.

Like Linux you will now run a few commands:

```bash
VMID=302
LG_USER="domain_user"
# Below commands in Proxmox SSH
qm set $VMID --hookscript=local-btrfs:snippets/pve-helper
cat << EOF >> /etc/pve/qemu-server/$VMID.conf
tablet: 0
ivshmem: size=128
EOF
sed -E -i -e "s/^ide.*$//" -e "s/^sata.*$//" -e "s/^vga.*$/vga: none/" /etc/pve/qemu-server/$VMID.conf
echo "args: -uuid $(qm showcmd $VMID | sed -E "s_.*/(\w*-0000-0000-0000-\w*).*_\1_") -cpu host,hv_ipi,hv_relaxed,hv_reset,hv_runtime,hv_spinlocks=0x1fff,hv_stimer,hv_synic,hv_time,hv_vapic,hv_vendor_id=AuthenticAMD,hv_vpindex,kvm=off,+kvm_pv_eoi,+kvm_pv_unhalt,-hypervisor -device virtio-mouse-pci -device virtio-keyboard-pci -device virtio-serial-pci -chardev spicevmc,id=vdagent,name=vdagent -device virtserialport,chardev=vdagent,name=com.redhat.spice.0 -spice addr=0.0.0.0,port=5900,disable-ticketing=on" >> /etc/pve/qemu-server/$VMID.conf
```

You will then decide if you only want to access Looking Glass from local Proxmox host, or via network (like from Linux VM). If you want to allow network access, you will need to use a normal socket for SPICE. Replace

```
-spice addr=0.0.0.0,port=5900,disable-ticketing=on
```

with this

```
-spice unix=on,addr=/run/lg$VMID.socket,disable-ticketing=on
```

We suggest you reboot Proxmox once you finish set up before you boot both Linux and Windows VM up with intention to use VM-to-VM Looking Glass. Sometimes Proxmox will create IVSHMEM file with a different inode, so VM stops talking to each other. Reboot gurantees they will have the same inode.
