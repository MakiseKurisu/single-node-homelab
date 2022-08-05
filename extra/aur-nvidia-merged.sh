#!/bin/bash

# Alternative method to install merged driver
# To uninstall:
# dkms remove nvidia/$_gridpkgver
# apt autoremove nvidia-merged

set -e

# TUNA mirror
mkdir -p ~/.cargo
cat << EOF > ~/.cargo/config
[source.crates-io]
replace-with = 'tuna'

[source.tuna]
registry = "https://mirrors.tuna.tsinghua.edu.cn/git/crates.io-index.git"
EOF

# Install PVE specific packages, so dkms won't pull generic Debian packages
apt install -y pve-headers pve-kernel-libc-dev
apt install -y git build-essential mdevctl dkms rustc librust-pam-dev xinit
# Extra packages for AUR build
apt install -y libarchive-tools ruby
gem sources --add https://mirrors.tuna.tsinghua.edu.cn/rubygems/ --remove https://rubygems.org/
which fpm || gem install fpm

# Checkout build files
git clone https://aur.archlinux.org/nvidia-merged.git || true
# Need to have NVIDIA driver pre downloaded
cp *.run ~/nvidia-merged
pushd ~/nvidia-merged
git checkout 138d419dacda8d27108a31cd41266b564ebd1d4e
git clone https://github.com/mbilker/vgpu_unlock-rs.git || true
pushd vgpu_unlock-rs
git checkout 6deede6a655bcf20eb50d73e5b5e9f745ac4652b
popd

rm -rf .root
mkdir -p .root

srcdir="$PWD"
pkgdir="$PWD/.root"
CARCH="x86_64"
source PKGBUILD

prepare

pushd .
build
popd

package_nvidia-merged-dkms
package_nvidia-merged-settings
package_nvidia-merged-utils

fpm -s dir -t deb -n "$pkgbase" -v "$pkgver-$pkgrel" \
        --deb-compression none \
        -a amd64 \
        --force \
        "$pkgdir/"=/

dpkg -i "${pkgbase}_${pkgver}-${pkgrel}_amd64.deb"

dkms install nvidia/$_gridpkgver

systemctl enable nvidia-vgpud.service nvidia-vgpu-mgr.service

popd
