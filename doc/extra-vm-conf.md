# Additional VM configs

## Manjaro

```bash
yay -Syu --needed --noconfirm github-cli visual-studio-code-bin github-desktop-bin \
    manjaro-asian-input-support-fcitx5 fcitx5-chinese-addons \
    kicad \
    libreoffice-fresh chromium thunderbird \
    moonlight-qt-bin remmina freerdp \
    discord mattermost-desktop teams skypeforlinux-stable-bin deepin-wine-wechat deepin-wine-tim wemeet-bin v4l2loopback-dkms
yay -Syu --needed manjaro-pipewire
cat << EOF | sudo tee -a /etc/environment
MOZ_ENABLE_WAYLAND=1
GTK_IM_MODULE=fcitx
QT_IM_MODULE=fcitx
XMODIFIERS=@im=fcitx
EOF
cat << EOF | sudo tee /usr/share/applications/looking-glass-client.desktop
[Desktop Entry]
Version=1.0
Name=Looking Glass Client
Comment=Low latency framebuffer viewer
Exec=looking-glass-client
Terminal=false
X-MultipleArgs=false
Type=Application
Categories=Game;
StartupNotify=true
EOF
update-desktop-database
```

## Windows
