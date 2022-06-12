# Create Debian Guest

## Configure

```
apt update && apt install -y ssh && systemctl enable ssh && poweroff

su -
apt install -y bash-completion tmux sudo
apt install -y samba winbind libnss-winbind libpam-winbind krb5-user libpam-krb5
apt install -y systemd-timesyncd
timedatectl set-ntp true
systemctl enable --now serial-getty@ttyS0
nano /etc/network/interfaces
# Add `iface enp6s18 inet6 dhcp`
usermod -a -G sudo YOUR_USER
```