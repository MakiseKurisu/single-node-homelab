# Proxmox Workstation

In this section, we will set up a Proxmox-based VM host with virtual workstation capability. However, not everyone wants to run desktop directly on their server, so we offer 3 different configurations here:

1. No host GPU driver. VFIO passthrough only.
2. Install vGPU driver, but no desktop environment to view VM's graphic output locally.
3. Install vGPU driver, host driver, and X11 with Looking Glass to view and control VM locally.
4. X11 Multiseats with NVENC unlocked so 4 users can run Looking Glass simultaneously a.k.a da dream.

I planned to go with 3 initially and develop a solution for 4, but found out that Looking Glass's Linux host is immature at this moment, and there is way to much to install to for a mere Moonlight access. I'm currently going with 2, and passed RX460 to Linux with PRIME to run games on vGPU.

If you primarily use Windows and accept only accessing Linux via Moonlight, then you can go with 3.

The setup process has been roughly divided into those 3 parts, so just follow along and skip the section you don't need.

## Hardware configuration

- ASRock ~~Fatal1ty X370 Professional Gaming~~ X370 Taichi P7.10 Motherboard
- AMD Ryzen 7 3700X Processor
- Samsung DDR4 3200MHz 32GB Memory x2
- Samsung 970 Evo 1TB NVMe SSD
- Gigabyte 120GB SATA SSD
- NVIDIA Titan X GPU
- AMD RX460 GPU

## Proxmox installation tips

Config BIOS first. Enable virtualization-related features like VT-d, IOMMU, SR-IOV, above 4G decode, etc.

Install Proxmox as you wish. On disk setup, I use `btrfs` RAID-1 instead of `zfs`. If you choose differently you will need to update some scripts later on as currently the storage path is hardcoded (search `local-btrfs`). This principle applies whenever you deviate from the guide.

I also used to run Proxmox on dual USB thumb drives on an internal USB 3.0 header. However, occasionally one of the USB drives will be missing, `btrfs` will fail to mount, and Proxmox will stop booting. Manual reset fixes the issue but that doesn't play well with Wake-on-Lan. As such I just install Proxmox to a SATA SSD instead.

