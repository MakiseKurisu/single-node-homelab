# Hardware

As I'm managing a few different environments the hardware requirements are slightly different. Below suggestions are based on my personal environment.

## What specs should I look for?

First, check [`r/homelab`](https://www.reddit.com/r/homelab/wiki/index) and [`r/DataHoarder`](https://www.reddit.com/r/homelab/wiki/index) wiki. Their hardware guides should give you a good start.

### Case

For the case, I prefer ATX tower with a lot of hard drive bays. I have built 2 NZXT Source 220 based systems (one sold when I moved and one currently in use) and am very happy about this case. Sadly this cheap case is no longer in manufacture so you have to *source* it from 2nd hand market. It has 8 3.5-inch bays and 3 5.25 bays which can be adapted to 5 more 3.5-inch bays, giving you a total of 13 hard drive bays. Not all 8 3.5 bays are usable when GPU is plugged in, but that raw number combined with the fact that the price of an 18TB hard drive has been bearable due to crypto crash means this case can meet a lot of people's storage need.

If you cannot find a used Source 220, NZXT H2 has the same internal but worse cooling. From the same era Fractal Design R3 has 1 less 5.25 bay but 3.5 bays are more accessable and cooling is better than H2. For something current Fractal Design Meshify 2 (or XL) will be my next choice. Non XL with 11 3.5 bays can fulfill most users' need, but if you need more drives XL can equip up to 18 disks. Case has a very long life so if you are OK with how big it is this case should last you a long time.

### Power supply

Give 200W budget per CPU and 300W per GPU with 10W per disk, and buy PSU accordingly. Effiency is maxed around 50% load so it's okay to buy an oversized PSU. I'm running Seasonic FOCUS GX-850 for a 1C1G configuration with plan to add 2nd GPU in the future. Like the case, PSU last a long time, and a beefy one can be used longer. 2nd hand PSU is **strongly discouraged**, and only quality brands may be considered. The first system I built had an used Corsair PSU, and that one was fine. On my current system I did that again with a lower tier OEM because their used PSU has high wattage, and in the end I have 3 failed PSU, broken motherboard, and failed CPU.

### Platform

AM4 platform is EOL but there is still plenty of life left in this platform. You can also use AM4 cooler on AM5 so get a good one. Motherboards are recommended in the following order:

1. ASRock Fatal1ty X370 Professional Gaming (what I was using)
2. ASRock X470 Taichi Ultimate
3. ASRock X370 Taichi (currently using)
4. X570 boards with multi-gig Ethernet, but just get ASRock X370 Taichi

This is mostly based on network connectivity. X370 PG is the only X370 with 5GbE and X470 TU is the only X470 with 10GbE (excluding the ASRock Rack offering which is a lot more expensive). Being the halo products they, unfortunately, have very limited availability (especially X470 TU). In that case, I'll just go with X370 Taichi which is X370 PG minus the 5GbE, and rely on a USB or PCIe network card if I do need the extra port or bandwidth.

This bias for ASRock is also due to them being the first vendor to support Ryzen 5000 series on their X370 motherboard long before AMD eased the restriction, making them the only choice for the cheap used motherboard. Right now a lot of other vendors have added the support on their X370 boards as well, but they do not have better NIC so the calculation is still the same.

One final thing is [IOMMU group](https://wiki.archlinux.org/title/PCI_passthrough_via_OVMF#Ensuring_that_the_groups_are_valid). Motherboard with good IOMMU grouping means you can easily pass devices to the guest. ACS override is a hack and a source of instability so I don't think it is worth doing. For X370PG (and likely Taichi) the 2 X8/16 slots and the M.2 slot are all in separate IOMMU groups so you can use them for GPU passthrough. As for motherboard peripherals, most of them are in the same group except for the USB 3.0 controller and the audio controller. Not the best but I can live with this.

For CPU I'm currently using Ryzen 7 3700X which is the generation where AMD's gaming performance caught up with Intel and before they jacked up the price on 5000 series. 3700X being the cheaper 8-core offering from this generation with a box cooler means you can get them together for cheap. If your budget cannot afford this you can check earlier 8-core offering 1700/2700, as well as 6-core offering 1600AF/3600, based on your requirement of single and multi-threaded performance.

Moving forward there is also an upgrade path of 3900X/3950X and 5900X/5950X. 5900X is the most likely candidate for the improved core count and IPC, while likely being cheaper per core than 5950X in a few years. After 5900X is no longer performant AM5 platform and DDR5 should be mature enough with a good 2nd hand market.

### Memory

Right now I'm using 2x32GB 3200MHz ECC ram. My workstation has been 32GB for a long time so pairing another 32GB for services and 2nd GPU VM makes sense. This also leaves me an upgrade path to 128GB memory should I need that much (which can be possible if using vGPU for virtual desktops). So the recommendation is to put the double amount of memory you are currently using to the host.

### GPU

To use [vGPU unlock](https://github.com/DualCoder/vgpu_unlock), you need Maxwell/Pascal/Turing based Nvidia GPU and a good amount of vram to be useful. Some recommended cards are Tesla M40/P40 24GB for dedicated vGPU, or Geforce Titan X (Pascal) / Geforce GTX 1080 Ti for using the combined driver. Those cards have a good amount of vram while fast enough to be comfortably shared by many guests. Since we only have 2-3 PCIe slots for GPU a cheaper one basically "wastes" it, but they can be used nonetheless. With a Titan X you don't have to mess with cooling and can use as a passthrough GPU for now. Once you need a better GPU (that may not be supported by vGPU unlock), you can still share it with guests, maximizing the use-value.