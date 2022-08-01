# Set up Samba Active Directory Domain Controller

In this chapter, we will set up an AD domain controller with DNS and NTP services.

## Install dependency

To be updated

```
sudo apt install -y smbclient ntp
```

## Preparation

If you follow [Debian guest](./debian-guest.md) chapter then below are all you need to do. Otherwise, check [the official Samba Wiki](https://wiki.samba.org/index.php/Setting_up_Samba_as_an_Active_Directory_Domain_Controller#Preparing_the_Installation).

```
sudo systemctl disable --now smbd nmbd winbind
sudo sed -nie "p; s/127.0.1.1/$(ip -o -6 addr | grep -v -e "1: lo" -e "dynamic" -e "link" | head -n 1 | awk '{print $4}' | cut -d/ -f1)/p" /etc/hosts
sudo sed -ie "s/127.0.1.1/$(ip -o -4 addr | grep -v "1: lo" | awk '{print $4}' | cut -d/ -f1)/" /etc/hosts
sudo rm -rf /etc/samba/smb.conf /run/samba /var/lib/samba /var/cache/samba /etc/krb5.conf
sudo mkdir -p /var/lib/samba/private
```

## Provision

Default configs work fine so just need to put your password here:
```
sudo samba-tool domain provision --interactive --use-rfc2307
sudo nano /etc/samba/smb.conf
#
# Add the following line in [global] section
#
# template shell = /bin/bash
# template homedir = /home/%U
# winbind use default domain = yes
#
sudo sed -i -e "s/passwd:\s*files/passwd: files winbind/" -e "s/group:\s*files/group: files winbind/" /etc/nsswitch.conf
echo "session required pam_mkhomedir.so" | sudo tee -a /etc/pam.d/common-session
echo "domain YOUR.DNS.DOMAIN" | sudo tee -a /etc/resolv.conf
echo "search YOUR.DNS.DOMAIN" | sudo tee -a /etc/resolv.conf
sudo cp /var/lib/samba/private/krb5.conf /etc/krb5.conf
sudo sed -ie "s/default kod notrap nomodify nopeer noquery limited/default kod notrap nomodify nopeer limited mssntp/g" /etc/ntp.conf
echo "ntpsigndsocket /var/lib/samba/ntp_signd/" | sudo tee -a /etc/ntp.conf
sudo chown root:ntp /var/lib/samba/ntp_signd
sudo systemctl restart ntp
```

Now update your OpenWrt setting to use AD DC's DNS:
```
uci set dhcp.@dnsmasq[0].domain='YOUR.DNS.DOMAIN'
uci set dhcp.@dnsmasq[0].local='/YOUR.DNS.DOMAIN/AD.DOMAIN.CONTROLLER.IP'
uci add_list dhcp.guest.dhcp_option='42,AD.DOMAIN.CONTROLLER.IP' # NTP Server
uci commit
/etc/init.d/dnsmasq restart
```

## Check if AD DC is working

```
AD_REALM=SAMDOM.EXAMPLE.COM
DC=DC01

sudo samba # automatically running in the background
smbclient -L localhost -N
smbclient //localhost/netlogon -UAdministrator -c 'ls'
host -t SRV _ldap._tcp.${AD_REALM}
host -t SRV _kerberos._udp.${AD_REALM}
host -t A ${DC}.${AD_REALM}.
kinit administrator
klist
```

## Enable Sambe permanently

```
sudo systemctl unmask samba-ad-dc
sudo systemctl enable samba-ad-dc
sudo reboot
```

## Reference
[Samba Wiki](https://wiki.samba.org/index.php/Setting_up_Samba_as_an_Active_Directory_Domain_Controller)
[Samba Wiki-Winbind](https://wiki.samba.org/index.php/Configuring_Winbindd_on_a_Samba_AD_DC)
[Arch Wiki](https://wiki.archlinux.org/title/Samba/Active_Directory_domain_controller)