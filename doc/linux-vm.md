# Create Linux VM with dGPU/vGPU and Sunshine

The reason we want to create Linux VM with dGPU is because Looking Glass Linux Host is immature. Also you cannot passthrough vGPU with other PCIe devices, so there goes the dream to run dGPU and vGPU using PRIME. But no matter which GPU you choose, the way to do it is pretty similar, so we will have them here together.

Create your Linux VM in Proxmox's GUI. Some personal perferences and tips with important one in bold:

- Infrastrucure VMID start at 101, Service VMID starts at 201, and Client VMID starts at 301. In `Datacenter`-`Options`-`Next Free VMID Range` you can set to `301-399` for your Client VMs.
- VMID is also mapped to IP address from XYY to 192.168.X.YY. This is done in the router with static DHCP lease.
- Enable `Start at boot` so unprivileged users can use VM without additional settings.
- Under `System` tab, use `q35` machine, `OVMF (UEFI)` BIOS,` VirtIO-GPU` graphic card, `VirtIO SCSI Single` SCSI controller, and check `Add TPM` & `Qemu Agent`.
- **Uncheck `Pre-Enroll keys` in `System` tab!** This will [enable Secure Boot](https://192.168.2.191:8006/pve-docs/chapter-qm.html#qm_bios_and_uefi) which is not what we want with [Looking Glass driver](https://looking-glass.io/docs/B5.0.1/install/#installing-the-ivshmem-driver), or with unsigned kernel like Arch or Manjaro.
- For `Disks` tab, use `SCSI` bus, check `Discard`, `SSD emulation`, and `IO thread`.
- **Use `Write through` for `Cache` in `Disks` tab!** [Btrfs honors `O_DIRECT`](https://pve.proxmox.com/pve-docs/chapter-pvesm.html#storage_btrfs) so need to use a [cache mode without this flag](https://pve.proxmox.com/wiki/Performance_Tweaks#Small_Overview).
- Use `host` CPU type.
- **Uncheck `Ballooning Device`!** This doesn't play nicely with Nvidia drivers and could make VM unusable.
- Use `VirtIO (paravirtualized)` network card.
- **Do not check `Start after created`!** We will make more changes before we start the VM.

After those steps I have created a VM with VMID `301`. Now go to `Hardware` and add `Serial Port` and `VirtIO RNG`, which are optional since you can also use SSH to control the VM. If you have no hardware audio card to passthrough you will need to add an `Audio Device`. If you have a working vGPU setup, you can now add `PCI Device` to your VM, and `Meditated Device` will say `Yes` for your GPU. Select it, choose the profile in `MDev Type`, and check every available options. Otherwise, just add your PCIe devices here.

Now start VM and install your favorite distro. Right now uou can use a Spice viewer like `virt-viewer` to control the VM, instead of Proxmox's noVNC web console. For distro I'm using Manjaro. Once everything is done, let's run the following commands in the Spice viewer or noVNC to enable remote access:

```bash
sudo systemctl enable --now sshd serial-getty@ttyS0
```

The reason we do this is that once you can remote console, you can copy and paste command in your local terminal, which is not something you can do with Proxmox's noVNC. You can then find the IP address on Proxmox's VM page. Here we will show you how to use the VirtIO serial console, since we will also run some commands in Proxmox as well:

```bash
PVE_IP="$(grep "ansible_host" hosts | tr -s ' ' | cut -d ' ' -f 3)"
ssh root@$PVE_IP
# Below commands in Proxmox SSH
VMID=301
qm terminal $VMID
#############
# You will see a message telling you that press Ctrl+O exit this terminal.
# Unlike SSH, Ctrl+O won't kill the current session.
#############
## Below commands in Manjaro Terminal
## Login with your account first
chsh -s /usr/bin/zsh
sudo sed -i "s/#ParallelDownloads/ParallelDownloads/" /etc/pacman.conf
sudo pacman-mirrors -c China # Obviously use something else if you are not in China
sudo pacman -Syu --noconfirm yay
yay -S --noconfirm --needed base-devel linux515-headers dkms looking-glass obs-plugin-looking-glass looking-glass-module-dkms sunshine plasma-wayland-session
cat << EOF > /etc/X11/xorg.conf.d/20-amdgpu.conf
Section "Device"
     Identifier "AMD"
     Driver "amdgpu"
     Option "VariableRefresh" "true"
EndSection
EOF
# Update user below to match your username
cat << EOF | sudo tee /etc/tmpfiles.d/10-looking-glass.conf
#Type Path        Mode UID  GID  Age Argument
f     /dev/kvmfr0 0660 user root -
EOF
sudo poweroff
# Now you are back in Proxmox SSH
```

```bash
# Below commands in Proxmox SSH
qm set $VMID --hookscript=local-btrfs:snippets/pve-helper
sed -i -E -e 's/^vga:.*$/vga: none/' -e 's/^ide2:.*$//' /etc/pve/qemu-server/$VMID.conf
cat << EOF >> /etc/pve/qemu-server/$VMID.conf
tablet: 0
ivshmem: size=64,name=302
EOF
echo "args: -uuid $(qm showcmd $VMID | sed -E "s_.*/(\w*-0000-0000-0000-\w*).*_\1_") -cpu host,-hypervisor,kvm=off,hv_vendor_id=AuthenticAMD,topoext -device virtio-mouse-pci -device virtio-keyboard-pci -spice unix=on,addr=/run/lg$VMID.socket,disable-ticketing=on -device virtio-serial-pci -chardev spicevmc,id=vdagent,name=vdagent -device virtserialport,chardev=vdagent,name=com.redhat.spice.0" >> /etc/pve/qemu-server/$VMID.conf
qm start $VMID
# Leave this SSH session running, as we will use it during Windows setup
```

We put `name=302` in `$VMID.conf` because by default, Proxmox will create IVSHMEM file suffixed with your VMID. However, we want to access Windows (VMID will be 302) through Looking Glass, so we need to match the name for IVSHMEM file.

The last command starts the VM for you.

## To do

lg client config

kvmfr0 permission
