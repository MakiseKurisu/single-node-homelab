# Create Debian Guest

## Configure

If you did not install SSH server task during your Debian installation, you can run the following command:

```
# Login as root
apt update
apt install -y ssh
systemctl enable ssh
```

Then run the following command:

```
./bootstrap -U your_ssh_user -p your_ssh_pass -l infra_debian copy-id
./bootstrap ansible debian-init
```

It will ask your root password as BECOME password. Make sure they are the same in all machines.