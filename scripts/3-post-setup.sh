#!/usr/bin/env bash
#github-action genshdoc
echo -ne "
-------------------------------------------------------------------------
   █████╗ ██████╗  ██████╗██╗  ██╗████████╗██╗████████╗██╗   ██╗███████╗
  ██╔══██╗██╔══██╗██╔════╝██║  ██║╚══██╔══╝██║╚══██╔══╝██║   ██║██╔════╝
  ███████║██████╔╝██║     ███████║   ██║   ██║   ██║   ██║   ██║███████╗
  ██╔══██║██╔══██╗██║     ██╔══██║   ██║   ██║   ██║   ██║   ██║╚════██║
  ██║  ██║██║  ██║╚██████╗██║  ██║   ██║   ██║   ██║   ╚██████╔╝███████║
  ╚═╝  ╚═╝╚═╝  ╚═╝ ╚═════╝╚═╝  ╚═╝   ╚═╝   ╚═╝   ╚═╝    ╚═════╝ ╚══════╝
-------------------------------------------------------------------------
                    Automated Arch Linux Installer
                        SCRIPTHOME: ArchTitus
-------------------------------------------------------------------------

Final Setup and Configurations
GRUB EFI Bootloader Install & Check
"
source ${HOME}/ArchTitus/configs/setup.conf

if [[ -d "/sys/firmware/efi" ]]; then
    grub-install --efi-directory=/boot ${DISK}
fi

echo -ne "
-------------------------------------------------------------------------
               Creating (and Theming) Grub Boot Menu
-------------------------------------------------------------------------
"
# set kernel parameter for decrypting the drive
if [[ "${FS}" == "luks" ]]; then
sed -i "s%GRUB_CMDLINE_LINUX_DEFAULT=\"%GRUB_CMDLINE_LINUX_DEFAULT=\"cryptdevice=UUID=${ENCRYPTED_PARTITION_UUID}:ROOT root=/dev/mapper/ROOT %g" /etc/default/grub
fi
# skip grub menu
sed -i 's/^GRUB_TIMEOUT=5/GRUB_TIMEOUT=0/' /etc/default/grub
if [[ $PARTITION_STRATEGY == "Dual_Boot" ]]; then
  sed -i 's/^#GRUB_DISABLE_OS_PROBER=false/GRUB_DISABLE_OS_PROBER=false/' /etc/default/grub
fi
grub-mkconfig -o /boot/grub/grub.cfg
echo -e "All set!"

echo -ne "
-------------------------------------------------------------------------
               Enabling (and Theming) Login Display Manager
-------------------------------------------------------------------------
"
if [[ ${DESKTOP_ENV} == "kde" ]]; then
  systemctl enable sddm.service
  # if [[ ${INSTALL_TYPE} == "FULL" ]]; then
  #   echo [Theme] >>  /etc/sddm.conf
  #   echo Current=Nordic >> /etc/sddm.conf
  # fi

elif [[ "${DESKTOP_ENV}" == "gnome" ]]; then
  systemctl enable gdm.service

elif [[ "${DESKTOP_ENV}" == "lxde" ]]; then
  systemctl enable lxdm.service

elif [[ "${DESKTOP_ENV}" == "i3" ]]; then
  systemctl enable lightdm

elif [[ "${DESKTOP_ENV}" == "openbox" ]]; then
  systemctl enable lightdm.service
  # if [[ "${INSTALL_TYPE}" == "FULL" ]]; then
  #   # Set default lightdm-webkit2-greeter theme to Litarvan
  #   sed -i 's/^webkit_theme\s*=\s*\(.*\)/webkit_theme = litarvan #\1/g' /etc/lightdm/lightdm-webkit2-greeter.conf
  #   # Set default lightdm greeter to lightdm-webkit2-greeter
  #   sed -i 's/#greeter-session=example.*/greeter-session=lightdm-webkit2-greeter/g' /etc/lightdm/lightdm.conf
  # fi

else
  if [[ ! "${DESKTOP_ENV}" == "server"  ]]; then
  sudo pacman -S --noconfirm --needed lightdm lightdm-gtk-greeter
  systemctl enable lightdm.service
  fi
fi


echo -ne "
-------------------------------------------------------------------------
                    Enabling Essential Services
-------------------------------------------------------------------------
"
systemctl enable cups.service
echo "  Cups enabled"
systemctl enable bluetooth
echo "  Bluetooth enabled"

if [[ "${FS}" == "luks" || "${FS}" == "btrfs" ]]; then
    echo -ne "
    -------------------------------------------------------------------------
                        Creating Snapper Config
    -------------------------------------------------------------------------
    "
    # snapper is the snapshot-btrfs tool helper
    SNAPPER_CONF="$HOME/ArchTitus/configs/etc/snapper/configs/root"
    mkdir -p /etc/snapper/configs/
    cp -rfv ${SNAPPER_CONF} /etc/snapper/configs/

    SNAPPER_CONF_D="$HOME/ArchTitus/configs/etc/conf.d/snapper"
    mkdir -p /etc/conf.d/
    cp -rfv ${SNAPPER_CONF_D} /etc/conf.d/
fi

echo -ne "
-------------------------------------------------------------------------
                    Cleaning
-------------------------------------------------------------------------
"
# Remove no password sudo rights
sed -i 's/^%wheel ALL=(ALL) NOPASSWD: ALL/# %wheel ALL=(ALL) NOPASSWD: ALL/' /etc/sudoers
sed -i 's/^%wheel ALL=(ALL:ALL) NOPASSWD: ALL/# %wheel ALL=(ALL:ALL) NOPASSWD: ALL/' /etc/sudoers
# Add sudo rights
sed -i 's/^# %wheel ALL=(ALL) ALL/%wheel ALL=(ALL) ALL/' /etc/sudoers
sed -i 's/^# %wheel ALL=(ALL:ALL) ALL/%wheel ALL=(ALL:ALL) ALL/' /etc/sudoers

# rm -r $HOME/ArchTitus
# rm -r /home/$USERNAME/ArchTitus
rm /home/$USERNAME/ArchTitus/configs/setup.conf # remove password!

# Replace in the same state
cd $pwd
