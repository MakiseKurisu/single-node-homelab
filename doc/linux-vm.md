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

After those steps I have created a VM with VMID `301`. Now go to `Hardware` and add `Serial Port` and `VirtIO RNG`, which are optional since you can also use SSH to control the VM. If you have no hardware audio card to passthrough you will need to add an `Audio Device`. If you have a working vGPU setup, you can now add `PCI Device` to your VM, and `Meditated Device` will say `Yes` for your GPU. Select it, choose the profile in `MDev Type`, and check every available options. Otherwise, just add your other PCIe devices here.

If you use dGPU it is easier to set `Display` to `none` here, add your dGPU, and install on your physical screen, so the driver is auto installed by your installer. This is the case for Manjaro, where installing with both dGPU and Virtio-GPU results in no graphical shell in either places, and installing with Virtio-GPU only results in blackscreen once switched to AMD dGPU. If your distro have better support on graphic, you can have both enabled, or only Virtio-GPU. This way you can use `virt-viewer` to control the VM, instead of Proxmox's noVNC web console or hooking up additional hardware.

Once you can log in the guest system, let's run the following commands to enable remote access:

```bash
sudo systemctl enable --now sshd
ip a
```

The reason we do this is that once you can remote console, you can copy and paste command in your local terminal, which is not something you can do with Proxmox's noVNC. Here we will show you how to use the VirtIO serial console:

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
logout
# Relog in to switch shell
sudo sed -i "s/#ParallelDownloads/ParallelDownloads/" /etc/pacman.conf
# Obviously use something else if you are not in China
sudo pacman-mirrors -c China
sudo pacman -Syu --noconfirm yay
yay -S --noconfirm --needed base-devel linux515-headers looking-glass obs-plugin-looking-glass looking-glass-module-dkms sunshine plasma-wayland-session qemu-guest-agent
sudo systemctl enable --now serial-getty@ttyS0 qemu-guest-agent
# Update user below to match your username
cat << EOF | sudo tee /etc/udev/rules.d/99-kvmfr.rules
SUBSYSTEM=="kvmfr", OWNER="user", GROUP="root", MODE="0660"
EOF
cat << EOF > ~/.looking-glass-client.ini
[app]
shmFile=/dev/kvmfr0

[win]
fullScreen=yes
autoResize=yes
jitRender=no # yes will crash X11 server. DO NOT ENABLE!

[input]
rawMouse=yes

[spice]
host=192.168.1.1 # change to your Windows VM IP
port=5900
captureOnStart=yes

EOF
sudo poweroff
# Now you are back in Proxmox SSH
```

Now we will need to some additional settings to enable VM to VM Looking Glass access:

```bash
VMID=301
# Below commands in Proxmox SSH
qm set $VMID --hookscript=local-btrfs:snippets/pve-helper
cat << EOF >> /etc/pve/qemu-server/$VMID.conf
tablet: 0
ivshmem: size=128,name=302
EOF
sed -E -i "s/^ide2.*$//" /etc/pve/qemu-server/$VMID.conf
```

We put `name=302` in `$VMID.conf` because by default, Proxmox will create IVSHMEM file suffixed with your VMID. However, we want to access Windows (VMID will be 302) through Looking Glass, so we need to match the name for IVSHMEM file.

Now you have complete your Linux VM setup.
