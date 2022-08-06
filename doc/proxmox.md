# Set up Proxmox

## Prepare host

Since we will perform a lot of system configurations throughout this guide, I have created some Ansible playbooks to automate the task for you. You can download this repo to get it:

```bash
git clone --depth 1 https://github.com/MakiseKurisu/single-node-homelab.git
cd single-node-homelab
```

Unless otherwise noted, we will always **start** running command from this folder. The command itself might lead you to somewhere else, but we will take you back in the end. We also assume you are running those commands under Linux. For Windows users you can install WSL2 and start following from there.

Now let's prep the Proxmox server to allow Ansible configuration, and also set some varibles for this project:

```bash
./bootstrap provision proxmox_fqdn
# or when running non interactively, find out the available options
# Currently there is TUNA mirror option for users in China, and merged driver option for NVIDIA card to output graphic on Proxmox
./bootstrap
```

Some options are used later on if you don't know what they are for, but defaults should be sane enough for most people.

## Basic Proxmox Configuration

Run the following command in the same folder to perform some basic Proxmox setup:

```bash
# Review the tasks...
./bootstrap ansible proxmox-init --list-tasks
# and run!
./bootstrap ansible proxmox-init
```

The playbook will install 2 helper scripts. `lsiommu` will show you the IOMMU grouping on your machine. While `pve-helper` is a PVE snippet that can run some configuration tasks when you start/stop a VM.

Before you continue to the next chapter, we recommend you to first download the necessary system ISO and drivers first. Luckily `bootstrap` can do most of those for you, except for the Windows ISO. Go to [Microsoft](https://www.microsoft.com/software-download/windows11) to download Windows 11 ISO, and save it to the `resource` folder. We will also download some additional ISOs, and upload them to Proxmox here:

```bash
mkdir -p ./resource
wget --content-disposition -P "./resource" "some_microsoft_iso_link" &
./bootstrap iso --all
```

Some commands later on expect the necessary files are already downloaded in `./resource` folder.
