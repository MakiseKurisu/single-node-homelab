# Introduction

> Self hosting at home doesn't mean you need server racks or used enterprise leaf blowers. In fact, you could start with your existing gaming PC.

## A little bit of background

Back when I was still a college student, a laptop was all I need. My music and games went everywhere with me, along with my study material. There was no need to host them elsewhere since I need to bring my laptop anyway.

After graduating, I no longer need to bring my laptop with me to work, and the game I was playing was CPU and GPU bounded, so a gaming tower was on my wish list. Coincidentally, as I also needed to do some IT works for the company, I discovered [`r/homelab`](https://www.reddit.com/r/homelab/) while learning different hypervisors. I had never heard about [Proxmox](https://www.proxmox.com/en/) until `r/homelab` introduced it to me.

Fast forwards a few years, I have set up multiple single-node Proxmox installations for various personal and professional needs. I feel like right now is the time for me to properly document my setup and process (I do have [some gists](https://gist.github.com/MakiseKurisu/) written that may or may not have helped me get the current job), so I can easily replicate my setup in the future, and also provide some resource back to the community.

## Why single node?

Single node is not a choice but a compromise. I wish to expand to a proper multi node HA setup soon, but the following conditions limited my ability to do so (which could happen to you as well):

1. Initial investment. Multi node setup requires a greater initial investment, while the benefit of higher up-time is not as important for personal and even some professional use. Single node setup usually uses existing hardware so the opportunity cost is way smaller.
2. Performance, heat, electricity, space, and noise with used enterprise type of equipments. A common way to reduce the initial investment is to use 2nd hand enterprise equipment, and pay more on the operational cost. However, this is not possible for me since A, the operational cost as a renter is not a small amount (I pay electricity at the above commercial rate for example) so I want to minimize those as well; and B, it is hard to fit cheap consumer GPU on the rack server and CPU on those are usually quite old and clock limited, so not ideal for gaming. My first virtualized host was a ThinkStation D30 with dual Xeon E5-2667v2, and it wasn't much faster than my Thinkpad W540 during gaming.

Currently, I'm eyeing ARM based hyper converged cluster as a cheaper way to have multi node cluster for service hosting. Then I can convert my single node host into a normal Linux machine for gaming. Until then, single node is the way for me.

## But homelab is for messing with the enterprise network and enterprise hypervisor and so on!

While this is true as that is what homelab means initially, right now `r/homelab` is more of a place for self-hosting home production infrastructure. Throughout this book, we are gonna host some services, set up VLANs, and create Active Directory domain with WPA-Enterprise wireless network. I think those are enterprisey enough to call what we create a homelab, and those are useful for small businesses (which is my background).

## Then why there are a lot of missing chapters?

For this book, I'm going to write it while I set up the system. Currently, I have 3 single node systems that need to be set up, so I'll pen the part I'm doing first before moving to other sections.