#!/bin/sh

#Font: https://wiki.archlinux.org/title/GNOME/Tips_and_tricks
#
#



gsettings set org.gnome.desktop.interface enable-animations false
gsettings set org.gnome.desktop.peripherals.keyboard numlock-state true
gsettings set org.gnome.desktop.peripherals.keyboard remember-numlock-state true
gsettings set org.gnome.SessionManager logout-prompt false
gsettings set org.gnome.desktop.interface cursor-blink true
gsettings set org.gnome.Terminal.Legacy.Settings confirm-close false
gsettings set org.gnome.settings-daemon.plugins.media-keys volume-step 2
gsettings set org.gnome.shell.app-switcher current-workspace-only false


gsettings set org.gnome.desktop.wm.preferences button-layout 'appmenu:minimize,maximize,close'
gsettings set org.gnome.desktop.wm.preferences resize-with-right-button true


sudo apt install preload
sudo apt install ubuntu-restricted-extras
