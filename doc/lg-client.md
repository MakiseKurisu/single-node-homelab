# Install Looking Glass client on Proxmox

Debian 11 does not ship `cage`, `sway` doesn't work once NVIDIA driver is installed (tried Debian shipped one and a community build), `weston` doesn't work as well. As such we will use `i3` to provide a minimal desktop environment to run Looking Glass.

```bash
./bootstrap ansible lg
```

We also customized `/etc/skel` a bit, so any new user we added later will run Looking Glass automatically when they log in.
