# Install vGPU driver

Run the following command to install vGPU or merged driver, along with `vgpu-unlock_rs`.

```bash
./bootstrap ansible vgpu
```

If you passed `-v` option during provision, we also installed `xinit` in this step so the NVIDIA driver can detect the correct Xorg folder.

The script is designed for Titan X and `nvidia-50` profile. For other configuration please edit `Patch vgpuConfig.xml` in `vgpu.yml` to fake a **vGPU capable card** (some options listed in [vGPU-Unlock-patcher](https://github.com/VGPU-Community-Drivers/vGPU-Unlock-patcher)) and a **Quadro card** with your desired profile in `profile_override.toml`. They do not use the same PCI device ID.
