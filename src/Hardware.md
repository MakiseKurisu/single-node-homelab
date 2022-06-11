# Hardware

As I'm managing a few different environments the hardware requirements are slightly different. Below suggestions are based on my personal environment.

## What specs should I look for?

First, check [`r/homelab`](https://www.reddit.com/r/homelab/wiki/index) and [`r/DataHoarder`](https://www.reddit.com/r/homelab/wiki/index) wiki. Their hardware guides should give you a good start.

### Case

For the case, I prefer ATX tower with a lot of hard drive bays. I have built 2 NZXT Source 220 based systems (one sold when I moved and one currently in use) and am very happy about this case. Sadly this cheap case is no longer in manufacture so you have to *source* it from 2nd hand market. It has 8 3.5-inch bays and 3 5.25 bays which can be adapted to 5 more 3.5-inch bays, giving you a total of 13 hard drive bays. Not all 8 3.5 bays are usable when GPU is plugged in, but that raw number combined with the fact that the price of an 18TB hard drive has been bearable due to crypto crash means this case can probably meet a lot of people's storage need.

If you cannot find a used Source 220, Fractal Design Meshify 2 XL will be my next choice. Yes, we just jumped from a cheap ass case to a top-of-the-line premium case, but ultimately Meshify 2 XL is the only other case that I know that can house even more hard drives AND a 3rd GPU. Most cases these days no longer prioritize hard drive bays so not a lot of choices are available. Case has a very long life so if you are OK with how big it is this case should last you a long time.

### Power supply

Aim for a modular power supply over 750W with the Gold rating or higher. Like the case, PSU last a long time, and a beefy one can survive multiple upgrade cycles when more hard drives or GPUs are added. 2nd hand PSU is not recommended but that was what I did anyway. On one hand, I still save money even when **2** failed and I had to buy the 3rd one. On the other hand downtime and playing your data with fire. I have mixed feelings but I probably will keep doing it just because I'm so cheap.

### Platform

AM4 platform is EOL but there is still plenty of life left in this platform. You can also use AM4 cooler on AM5 so get a good one. Motherboards are recommended in the following order:

1. ASRock Fatal1ty X370 Professional Gaming (what I'm using right now)
2. ASRock X470 Taichi Ultimate
3. ASRock X370 Taichi
4. X570 boards with multi-gig Ethernet, but just get ASRock X370 Taichi

This is mostly based on network connectivity. X370 PG is the only X370 with 5GbE and X470 TU is the only X470 with 10GbE (excluding the ASRock Rack offering which is a lot more expensive). Being the halo products they, unfortunately, have very limited availability (especially X470 TU). In that case, I'll just go with X370 Taichi which is X370 PG minus the 5GbE, and rely on a USB or PCIe network card if I do need the extra port or bandwidth.

This bias for ASRock is also due to them being the first vendor to support Ryzen 5000 series on their X370 motherboard long before AMD eased the restriction, making them the only choice for the cheap used motherboard. Right now a lot of other vendors have added the support on their X370 boards as well, but they do not have better NIC so the calculation is still the same.

For CPU I'm currently using Ryzen 7 3700X which is the generation where AMD's gaming performance caught up with Intel and before they jacked up the price on 5000 series. 3700X being the cheaper 8-core offering from this generation with a box cooler means you can get them together for cheap. If your budget cannot afford this you can check earlier 8-core offering 1700/2700, as well as 6-core offering 1600AF/3600, based on your requirement of single and multi-threaded performance.

Moving forward there is also an upgrade path of 3900X/3950X and 5900X/5950X. 5900X is the most likely candidate for the improved core count and IPC, while likely being cheaper per core than 5950X in a few years. After 5900X is no longer performant AM5 platform and DDR5 should be mature enough with a good 2nd hand market.


### Memory

Right now I'm using 2x32GB 3200MHz ECC ram. My workstation has been 32GB for a long time so pairing another 32GB for services and 2nd GPU VM makes sense. This also leaves me an upgrade path to 128GB memory should I need that much (which can be possible if using vGPU for virtual desktops). So the recommendation is to put the double amount of memory you are currently using to the host.

### GPU

To use [vGPU unlock](https://github.com/DualCoder/vgpu_unlock), you need Maxwell/Pascal/Turing based Nvidia GPU and a good amount of vram to be useful. Some recommended cards are Tesla M40/P40 24GB for dedicated vGPU, or Geforce Titan X (Pascal) / Geforce GTX 1080 Ti for using the combined driver. Those cards have a good amount of vram while fast enough to be comfortably shared by many guests. Since we only have 2-3 PCIe slots for GPU a cheaper one basically "wastes" it, but they can be used nonetheless. With a Titan X you don't have to mess with cooling and can use as a passthrough GPU for now. Once you need a better GPU (that may not be supported by vGPU unlock), you can still share it with guests, maximizing the use-value.