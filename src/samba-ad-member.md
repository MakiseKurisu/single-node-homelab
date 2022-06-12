# Join Samba Active Directory Domain

In this chapter, we will join our existing AD domain.

## Preparation

```
sudo systemctl stop smbd nmbd winbind
sudo rm -rf /etc/samba/smb.conf /run/samba /var/lib/samba /var/cache/samba /etc/krb5.conf
sudo mkdir -p /var/lib/samba/private
sudo sed -ie "s/^127.0.1.1.*$//" /etc/hosts
```

## Check if AD DNS is working

```
AD_REALM=SAMDOM.EXAMPLE.COM
DC=DC01

host -t SRV _ldap._tcp.${AD_REALM}
host -t SRV _kerberos._udp.${AD_REALM}
host -t A ${DC}.${AD_REALM}.
host AD.DOMAIN.CONTROLLER.IP
```

## Configure Kerberos and Samba

```
AD_REALM=SAMDOM.EXAMPLE.COM
WORKGROUP=SAMDOM

cat << EOF | sudo tee /etc/krb5.conf
[libdefaults]
    default_realm = ${AD_REALM}
    dns_lookup_realm = false
    dns_lookup_kdc = true
EOF

cat << EOF | sudo tee /etc/samba/smb.conf
[global]
    security = ADS
    workgroup = ${WORKGROUP}
    realm = ${AD_REALM}

    idmap config * : backend = autorid
    idmap config * : range = 10000-9999999

    username map = /usr/local/samba/etc/user.map

    template shell = /bin/bash
    template homedir = /home/%U
    winbind use default domain = yes
EOF

sudo mkdir -p /usr/local/samba/etc/
echo '!root = ${WORKGROUP}\Administrator' | sudo tee /usr/local/samba/etc/user.map
```

## Joining domain
```
sudo net ads join -U Administrator
sudo systemctl start smbd nmbd winbind
sudo sed -i -e "s/passwd:\s*files/passwd: files winbind/" -e "s/group:\s*files/group: files winbind/" /etc/nsswitch.conf
echo "session required pam_mkhomedir.so" | sudo tee -a /etc/pam.d/common-session
```

## Testing

```
wbinfo --ping-dc
getent passwd SAMDOM\\Administrator
getent group "SAMDOM\\Domain Users"
touch /tmp/samba_test
sudo chown "SAMDOM\\Administrator:SAMDOM\\Domain Users" /tmp/samba_test
ls -la /tmp/samba_test
```

## Reference

[Samba Wiki](https://wiki.samba.org/index.php/Setting_up_Samba_as_a_Domain_Member)
[Samba Wiki-Winbind](https://wiki.samba.org/index.php/Authenticating_Domain_Users_Using_PAM)