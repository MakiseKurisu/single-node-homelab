# Create Windows vWS with vGPU and Looking Glass

Create your Windows VM similarly to how we created Linux VM. In this example I created a VM with VMID `302`. You can also add the same optional devices, even serial since Windows also supports serial console in the form of Windows Emergency Management Services. What's not optional though, is that you need to add 2 `CD/DVD Drive`, with `virtio-win.iso` under IDE bus 0, and `lg-win.iso` under SATA bus 1. Settings here affect how Windows assigns drive letters, so if you are not following this setting, be careful later on when there is a path listed.

Now start VM and install Windows. When Windows Installer asks you `Where do you want to install Windows?`, click `Load driver`, and `Browse` `E:\amd64\w11` to install `Red Hat VirtIO SCSI pass-through controller`, **AND** `E:\NetKVM\w11\amd64\` to install `Red Hat VirtIO Ethernet Adapter`. Windows is moving towards more online services, and you have to use an online account in Home edition. Pro edition is *currently* unaffected, but let's install the network driver just in case.

During OOBE setup create an account **with password** or you won't be able to access the computer via RDP. One trick though is to create account **without password** then add password in `Settings` once you can access the desktop. This way I don't have to click through 3 password recovery questions. After OOBE is done, go to `Settings `-`System `-`Remote Desktop ` and enable RDP (and create your password), then install VirtIO drivers with everything selected (`E:\virtio-win-guest-tools.exe`). After drivers are installed, shutdown Windows, run `VMID=302` in your Proxmox SSH session, then add the vGPU and run the same configuration commands listed in the Linux section again except `qm start`.

You will then decide if you only want to access Looking Glass from local Proxmox host, or via network (like from Linux VM). If you want to allow network access, you will need to use a normal socket for SPICE. Replace

```
-spice unix=on,addr=/run/lg$VMID.socket,disable-ticketing=on
```

with this

```
-spice addr=0.0.0.0,port=5900,disable-ticketing=on
```

 run the following commands as well if you want to access VM with Looking Glass on Proxmox:

```bash
LG_USER="domain_user"
# We assume you will also set up Active Directory later, and an user called `domain_user` exist in your domain.
# If you want to add a local user, please use `adduser`, as this one will use /etc/skel to setup new user's home folder.
echo "#lg-chown $LG_USER" >> /etc/pve/qemu-server/$VMID.conf
qm start $VMID
```

After VM boots up, you will have to use RDP to log in. You need to install Nvidia driver, [IVSHMEM driver](https://looking-glass.io/docs/B5.0.1/install/#installing-the-ivshmem-driver) under `Win10\amd64` folder (**make sure it reads `IVSHMEM Device` in `Device Manager`**, not `PCI standard RAM Controller`), and Looking Glass, which all located under `D:\`. Go to `Services` and make sure `Looking Glass (host)` service is `Running`, and you have completed the Windows VM setup. Go back to Proxmox's GUI and delete those `CD/DVD Drive`. They will shown with a strike through line, as Proxmox can't change hardware configuration when VM is ruuning, but those will be applied automatically when VM is off (including when you reboot the server, as that will shutdown all VMs first).

Now login with your assigned user account on your Proxmox machine and start using Looking Glass.
