# Set up Samba Active Directory Domain Controller

In this chapter, we will set up an AD domain controller with DNS and NTP services.

```

## Provision

```
./bootstrap ansible samba-dc
```

Administrator password will be set randomly. Run `sudo smbpasswd Administrator` to set it.

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

smbclient -L localhost -N
smbclient //localhost/netlogon -UAdministrator -c 'ls'
host -t SRV _ldap._tcp.${AD_REALM}
host -t SRV _kerberos._udp.${AD_REALM}
host -t A ${DC}.${AD_REALM}.
kinit administrator
klist
```

## Reference
[Samba Wiki](https://wiki.samba.org/index.php/Setting_up_Samba_as_an_Active_Directory_Domain_Controller)
[Samba Wiki-Winbind](https://wiki.samba.org/index.php/Configuring_Winbindd_on_a_Samba_AD_DC)
[Arch Wiki](https://wiki.archlinux.org/title/Samba/Active_Directory_domain_controller)