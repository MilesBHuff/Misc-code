#!/bin/env bash
## Written by Miles B Huff, Copyfree (Ɔ) 2012 by CC0
##
clear #Part0
echo "  This script will set up your computer like Sweyn78's after a fresh install
of Kubuntu, Netrunner, or Linux Mint KDE.
  This script may screw up your computer if you have already set it up with
this script.  Please run each Part only once.
  Note also that this script requires root priveliges.
  If you are not root, please exit this script now and re-run it
with the necessary priveliges."
echo "  Do you wish to run this script?"
echo "y/n"; read ANSWER
if [ "$ANSWER" = "n" ] ; then
  echo "Exiting now..."
  exit 0
fi
COMPLETE=0
##
###################################################
clear #Part1
echo "Do Part1?"
echo "  Description: Copy over important system configuration files
from a recovery partition, sdb1"
echo "y/n"; read ANSWER
if [ "$ANSWER" = "y" ] ; then
  ## Mount STOR-S78-1 if unmounted and present at /dev/sdb1 and enter it
  ## (also works if previously mounted by label), then list contents
  mkdir /media/sdb1  # Create the mountpoint
  mount /dev/sdb1 /media/sdb1  # Mount the partition
  cd /media/sdb1/Backup; cd /media/STOR-S78-1/Backup
  ls -F -X --color=auto --group-directories-first
  ##
  echo "  Note: your fstab is about to be overwritten.  Please add the correct UUID's
for your partitions to /etc/fstab so that you can avoid having to boot
into a recovery CD"
  read -p "Press the [Enter] key to continue..."
  cp -rfv ./etc /; cp -rfv ./usr /; cp -rfv ./root /  # Copy in the custom settings
  ## Change to the root directory for unmounting of /dev/sdb1
  ## and for easy moving and linking in Part2
  cd /
  umount  /dev/sdb1    # Unmount the partition
  rm -rfv /media/sdb1  # Remove the mountpoint
  ##
  COMPLETE=1
  echo "Part1: Done"
  echo "  Paused after completing this part.  Resume?"
  echo "y/n"; read ANSWER
  if [ "$ANSWER" = "n" ] ; then
    echo "Exiting now..."
    exit 1
  fi
fi
##
###################################################
clear #Part2 ~ RC
echo "Do Part2?"
echo "  Description: Automatically optimize configuration files."
echo "y/n"; read ANSWER
if [ "$ANSWER" = "y" ] ; then
  echo "Credits for these tips to:
https://wiki.archlinux.org/index.php/Maximizing_Performance
https://wiki.archlinux.org/index.php/Activating_Numlock_on_Bootup
https://wiki.archlinux.org/index.php/Laptop
https://wiki.archlinux.org/index.php/Improve_Boot_Performance
http://tuxradar.com/content/make-linux-faster-and-lighter
Others"
  ## Edits to /etc/sysctl.conf
  echo "
kernel.shmmax = 63554432

fs.inotify.max_user_watches = 65536
# fs.protected_hardlinks = 1
# fs.protected_symlinks = 1

net.ipv4.conf.all.accept_redirects = 0
net.ipv6.conf.all.accept_redirects = 0
net.ipv4.conf.all.accept_source_route = 0
net.ipv6.conf.all.accept_source_route = 0
net.ipv6.conf.all.forwarding = 0
net.ipv4.conf.all.rp_filter = 1
net.ipv4.conf.all.secure_redirects = 1
net.ipv4.conf.all.send_redirects = 0
net.ipv6.conf.all.use_tempaddr = 2
net.ipv6.conf.default.use_tempaddr = 2
net.ipv4.icmp_echo_ignore_broadcasts = 1
net.ipv4.icmp_ignore_bogus_error_responses = 1
net.ipv4.ip_forward = 0
net.ipv4.ip_no_pmtu_disc = 0
net.core.netdev_max_backlog = 2500
net.ipv4.route.flush = 1
net.ipv4.tcp_ecn = 0
net.ipv4.tcp_fack = 1
net.ipv4.tcp_no_metrics_save = 1
net.ipv4.tcp_rfc1337 = 1
net.ipv4.tcp_sack = 1
net.ipv4.tcp_syncookies = 1
net.ipv4.tcp_timestamps = 0
net.ipv4.tcp_window_scaling = 1
net.ipv4.tcp_rmem = 4096 87380 524288
net.ipv4.tcp_wmem = 4096 65536 524288
net.ipv4.tcp_mem = 524288 8388608 16777216
net.core.rmem_default = 87380
net.core.rmem_max = 16777216
net.core.wmem_default = 65536
net.core wmem_max = 16777216

vm.dirty_background_bytes = 4194304
vm.dirty_bytes = 4194304
vm.dirty_writeback_centisecs=1500
vm.laptop_mode=5
vm.swappiness=34
vm.vfs_cache_pressure=50
" >> /etc/sysctl.conf; sudo sysctl -p; echo "sysctl updated"
  ## Edits to /etc/rc.local
  echo "
for tty in /dev/tty?; do /usr/bin/setleds -D +num < \"$tty\"; done
{ echo ':DOSWin:M::MZ::/usr/bin/wine:' > /proc/sys/fs/binfmt_misc/register; } 2>/dev/null
  " >> /etc/rc.local; echo "rc.local updated"
  ## Edits to /etc/modprobe.d/modprobe.conf
  echo "
options usbcore autosuspend=1
/usr/sbin/iwpriv wlan0 set_power 5
hdparm -B 254 /dev/sda
" >> /etc/modprobe.d/modprobe.conf
#  ## Edits to /etc/modprobe.d/bad_list
#  echo "
#  alias net-pf-10 off" >> /etc/modprobe.d/bad_list
  echo "modprobe updated"
  ## Edits to /etc/pm/sleep.d/50-hdparm_pm
  echo "#!/bin/sh
if [ -n \"$1\" ] && ([ \"$1\" = \"resume\" ] || [ \"$1\" = \"thaw\" ]); then
  hdparm -B 254 /dev/sda > /dev/null
fi" >> /etc/pm/sleep.d/50-hdparm_pm; echo "50-hdparm_pm updated"
  chmod +x /etc/pm/sleep.d/50-hdparm_pm
  ## Edits to /etc/environment
  echo "KDE_NO_IPV6=True" >> /etc/environment; echo "environment updated"
  COMPLETE=1
  echo "Part2: Done"
  echo "  Paused after completing this part.  Resume?"
  echo "y/n"; read ANSWER
  if [ "$ANSWER" = "n" ] ; then
    echo "Exiting now..."
    exit 3
  fi
fi
##
###################################################
clear #Part3 ~ BETA, and dangerous
echo "Do Part3?  WARNING: BUGGY"
echo "  Description: Move large directories into /usr
for better speed and disk space usage"
echo "y/n"; read ANSWER
if [ "$ANSWER" = "y" ] ; then
  ## List contents of the current directory because listing is cool
  ls -F -X --color=auto --group-directories-first
  ## Create the directories for the moves
  mkdir /usr/cache
  ## Move size-intensive directories into /usr for better disk usage
  mv -Tfv /opt /usr/opr
  mv -Tfv /var/cache/apt /usr/cache/apt
  mv -Tfv /var/cache/apt-xapian-index /usr/cache/apt-xapian-index
  ## To correct an error caused by an older version of the following line;
  ## uncomment only if you fell victim to that bug.
  # rm -fv /opt; rm -fv /var/cache/apt; rm -fv /var/cache/apt-xapian-index
  ## Create symbolic links so that the movement of certain directories
  ## into /usr will work
  ln -Tfsv  /usr/opt  /opt  # Untested
  ln -Tfsv  /usr/cache/apt  /var/cache/apt  # Untested
  ln -Tfsv  /usr/cache/apt-xapian-index  /var/cache/apt-xapian-index  # Untested
  ## Symlinking mtab
  cp -va   /etc/mtab /etc/mtab.bak
  ln -fsv  /proc/self/mounts /etc/mtab
  ## Setting up bin and lib for cross compatibility
#  cp -vran  /bin/*  /usr/bin
#  cp -vran  /sbin/*  /usr/sbin
#  cp -vran  /lib/*  /usr/lib
#  cp -vran  /lib32/*  /usr/lib32
#  cp -vran  /lib64/*  /usr/lib64
  #
#  mkdir /bin.bak
#  mkdir /sbin.bak
#  mkdir /lib.bak
#  mkdir /lib32.bak
#  mkdir /lib64.bak
  #
#  cp -vraf  /bin/*  /bin.bak
#  cp -vraf  /sbin/*  /sbin.bak
#  cp -vraf  /lib/*  /lib.bak
#  cp -vraf  /lib32/*  /lib32.bak
#  cp -vraf  /lib64/*  /lib64.bak
  #
#  mkdir -v /!
#  ln -Tfsv  /usr/bin    /!/bin    &&  rsync -Khrav --delete-excluded /!/bin    /
#  ln -Tfsv  /usr/sbin   /!/sbin   &&  rsync -Khrav --delete-excluded /!/sbin   /
#  ln -Tfsv  /usr/lib    /!/lib    &&  rsync -Khrav --delete-excluded /!/lib    /
#  ln -Tfsv  /usr/lib32  /!/lib32  &&  rsync -Khrav --delete-excluded /!/lib32  /
#  ln -Tfsv  /usr/lib64  /!/lib64  &&  rsync -Khrav --delete-excluded /!/lib64  /
#  rm -rfv /!
  #
#  uname -a
#  su -c "uname -a"; echo "^^ If su doesn't work, /bin is broken"
#  sudo "uname -a"; echo "^^ If sudo doesn't work, /usr/bin is broken"
#  echo "  Paused after linking.  Delete Backups?"
#  echo "y/n"; read ANSWER
#  if [ "$ANSWER" = "y" ] ; then
#    rm -rfv /bin.bak
#    rm -rfv /sbin.bak
#    rm -rfv /lib.bak
#    rm -rfv /lib32.bak
#    rm -rfv /lib64.bak
#  fi
  ##
  COMPLETE=1
  echo "Part3: Done"
  echo "  Paused after completing this part.  Resume?"
  echo "y/n"; read ANSWER
  if [ "$ANSWER" = "n" ] ; then
    echo "Exiting now..."
    exit 3
  fi
  ## Update apt to save time in Part3
  add-apt-repository ppa:pitti/systemd
  sh /home/sweyn78/.local/scripts/getgpg.sh
fi
##
###################################################
clear #Part4
echo "Do Part4?"
echo "  Description: Set up system with apt"
echo "y/n"; read ANSWER
if [ "$ANSWER" = "y" ] ; then
  ## No real reason for the next two lines except that I like them.
  ## Yay, Bloat!  :D
  cd /usr/cache/
  ls -F -X --color=auto --group-directories-first
  echo "  Note that this Part will take a long time to complete,
as it will be downloading nearly 1000 packages on a fresh install."
  ## Readjust apt and get the system up to date
  apt-get upgrade -y; apt-get dist-upgrade -y
  echo "  Upgrade complete.  Beginning installation of new packages"
  ## Get and install the packages Sweyn78 desires on hir computer
  apt-get install -y apper zsh zsh-static fizsh apper qtcurve zram-config syslog-ng playonlinux unix-runescape-client freeciv-client-extras freeciv-data freeciv-sound-standard freeciv-client-gtk 0ad 0ad-data 0ad-data-common 0ad-data-update 0ad-dbg kolourpaint4 gimp gimp-data gimp-data-extras gimp-dds gimp-dimage-color gimp-gap gimp-gmic gimp-help-common gimp-help-en gimp-normalmap gimp-texturize libgimp2.0-doc inkscape fontforge fontforge-doc fontforge-extras fontforge-doc picasa kamoso cdebconf-gtk debconf-kde-helper debconf-utils gkdebconf xchat xchat-common xchat-gnome xchat-gnome-common xchat-otr preload extra-xdg-menus libxdg-basedir1 menu-xdg xdg-user-dirs lsb lsb-appchk3 lsb-build-base3 lsb-build-cc3 lsb-build-desktop3 lsb-core lsb-cxx lsb-desktop lsb-graphics lsb-invalid-mta lsb-languages lsb-multimedia lsb-printing lsb-qt4 lsb-security ia32-libs mintupdate mintwifi adobe-flash-properties-kde adobe-flashplugin gparted skype pidgin pidgin-extprefs pidgin-themes pidgin-plugin-pack pidgin-otr pidgin-openpgp pidgin-libnotify pidgin-latex pidgin-hotkeys pidgin-facebookchat pidgin-encryption apparmor-docs apparmor-notify apparmor-profiles apparmor-utils dh-apparmor libapparmor-perl python-libapparmor pithos pianobar enigmail thunderbird thunderbird-globalmenu thunderbird-locale-en-us firefox firefox-branding firefox-globalmenu firefox-kde-support firefox-gnome-support firefox-launchpad-plugin firefox-branding xul-ext-webaccounts xul-ext-websites-integration google-chrome-stable rekonq deluge deluge-common deluge-gtk gmusicbrowser smplayer smplayer-skins smplayer-themes smplayer-translations smtube shutter ristretto gtk-recordmydesktop audacity soundkonverter libreoffice libreoffice-base libreoffice-base-core libreoffice-calc libreoffice-common libreoffice-core libreoffice-draw libreoffice-ogltrans libreoffice-presentation-minimizer libreoffice-wiki-publisher scribus scribus-template vym speedcrunch kcharselect virtualbox-4.2 mintinstall granola granola-gui bleachbit gsmartcontrol libsmokekdeui4-3 driconf seahorse dropbox-index dropbox-share gstreamer1.0-plugins-ugly doc-linux-nonfree-html doc-linux-nonfree-text linux-firmware-nonfree ttf-xfree86-nonfree blender icc-profiles icc-utils xicc kgamma kde-config-qt-graphicssystem deepin-software-center xcalib gfxboot-themes-kde gfxboot-themes-upstream gfxboot-examples gfxboot freedesktop-sound-theme libx11-freedesktop-desktopentry-perl gir1.2-freedesktop supertux supertuxkart wine1.5-amd64 winetricks wine-gecko1.8 wine-mono0.0.8 gstreamer-tools libpostproc-extra-52 libavcodec-extra-53 libavfilter-extra-2 libavutil-extra-51 xscreensaver-gl-extra libavdevice-extra-53 lcdproc-extra-drivers gstreamer1.0-pulseaudio pulseaudio-equalizer pulseaudio-module-gconf pulseaudio-module-zeroconf ffmpeg ffmpeg2theora ffmpegthumbnailer kffmpegthumbnailer php5-ffmpeg libreoffice-gtk gnome-color-chooser overlay-scrollbar overlay-scrollbar-gtk2 overlay-scrollbar-gtk3 libreoffice-gnome libreoffice-gtk libreoffice-kde hardinfo praat kget libqt4-core lxappearance libqt4-gui libqt4-declarative-particles libqt4-declarative-shaders libqt4-webkit libqtgconf1 libsmokeqtcore4-3 libsmokeqtdbus4-3 libsmokeqtdeclarative4-3 libsmokeqtgui4-3 libsmokeqthelp4-3 libsmokeqtnetwork4-3 libsmokeqtopengl4-3 libsmokeqtsvg4-3 libsmokeqttest4-3 libsmokeqtscript4-3 libsmokeqtsvg4-3 libsmokeqtuitools4-3 libsmokeqtwebkit4-3 libsmokeqtxml4-3 libsmokeplasma3 libplasma4-perl kdeplasma-addons plasma-runners-addons gstreamer0.10-vaapi libva-intel-vaapi-driver intel-gpu-tools intel-microcode inteltool libopenvg1-mesa mesa-utils libosmesa6 libglw1-mesa gnome-media xserver-xorg-input-joystick xserver-xorg-input-kbd xserver-xorg-input-mtrack xvfb linux-base linux-container linux-crashdump linux-current-generic linux-doc linux-backports-modules-headers-quantal-generic linux-backports-modules-hv-quantal-generic linux-generic-lts-quantal linux-headers-generic-lts-quantal linux-hwe-generic linux-image linux-image-generic-lts-quantal linux-image-hwe-generic linux-signed-generic linux-signed-generic-lts-quantal linux-signed-image-generic-lts-quantal linux-tools linux-tools-common syslinux-themes-ubuntu-quantal gstreamer1.0-alsa gstreamer1.0-libav apper-appsetup kuser terminator aptitude envstore build-essential ibus ibus-doc tumbler-plugins-extra rootactions-servicemenu cmake gdebi-core gdebi-kde libcurl3-gnutls zenity ulatencyd dnsmasq
  echo "  Aptitude complete.  Installing source packages..."
  ## Export important environment variables
  export CFLAGS=\"-march=native -O2 -pipe -msse -msse2 -msse3 -mmmx -m3dnow\"
  export CXXFLAGS=\"${CFLAGS}\"
  su sweyn78 -cp "
  # Dolphin Emulator
  cd /tmp
  git clone https://code.google.com/p/dolphin-emu/ dolphin-emu
  cd dolphin-emu; mkdir Build && cd Build
  cmake ..
  make -j4 -k"
  make -j4 -k install
  cd /tmp
  cd /usr/cache
  su sweyn78 -cp "
  # verynice
  wget http://thermal.cnde.iastate.edu/~sdh4/verynice/down/verynice-1.1.tar.gz
  "
  su sweyn78 -cp "
  # Darling (Apple Emulator)
  # Instructions for use:  $ dyld osx-program arguments
  # For more info, see http://darling.dolezel.info/en/Build
  git clone --recursive git://github.com/LubosD/darling.git
  cd darling
  CC=clang CXX=clang++ cmake .
  make -j4 -k"
  make -j4 -k install
  # Continue with setup
  echo "  Installation complete.  Removing unneeded packages."
  apt-get remove -y xserver-xorg-video-openchrome xserver-xorg-input-vmmouse xserver-xorg-input-wacom xserver-xorg-input-all xserver-xorg-video-all xserver-xorg-video-ati xserver-xorg-video-cirrus xserver-xorg-video-mach64 xserver-xorg-video-mga xserver-xorg-video-modesetting xserver-xorg-video-neomagic xserver-xorg-video-qxl xserver-xorg-video-r128 xserver-xorg-video-radeon xserver-xorg-video-s3 xserver-xorg-video-savage xserver-xorg-video-siliconmotion xserver-xorg-video-sis xserver-xorg-video-sisusb xserver-xorg-video-tdfx xserver-xorg-video-trident xserver-xorg-video-vmware bluedevil pulseaudio-module-bluetooth gnome-settings-daemon kamera
  ## Cleanup
  echo "  Performing post-setup tasks..."
  dpkg --configure -a      # Configure installed packages
  apt-mark  auto           # Mark packages as automatically installed
  apt-get   autoremove -y  # Remove unneeded packages
  apt-get   autoclean      # Clean apt's cache
  echo "  Performing some reliability tasks..."
  mkdir ~/.steam/bin32/plugins/; ln -s /usr/lib32/mozilla/plugins/libflashplayer.so ~/.steam/bin32/plugins/
  ln -s ~/.config/menus/applications-merged ~/.config/menus/kde4-applications-merged
  ln -s /usr/local/bin/wine /usr/bin/wine
  COMPLETE=1
  echo "Part4: Done"
  echo "  Paused after completing this part.  Resume?"
  echo "y/n"; read ANSWER
  if [ "$ANSWER" = "n" ] ; then
    echo "Exiting now..."
    exit 4
  fi
fi
##
###################################################
clear #Part5
echo "Do Part5?"
echo "  Description: Manually configure the system"
echo "y/n"; read ANSWER
if [ "$ANSWER" = "y" ] ; then
  cd ~/
  gkdebconf-gtk   # Configure the system
  systemsettings  # Konfigure the system
  echo "  Please add the correct UUID's for your partitions to avoid having to boot
into a recovery CD."
  echo "  Would you like to edit /etc/fstab now?"
  echo "y/n"; read ANSWER
  if [ "$ANSWER" = "y" ] ; then
    nano /etc/fstab   # Add the correct UUID's to fstab
  fi
  COMPLETE=1
  echo "Part5: Done"
  read -p "Press the [Enter] key to continue..."
fi
##
###################################################
clear #Part6
if [ "$COMPLETE" = "1" ] ; then
  echo "  Congratulations!  Your computer is now officially set up."
  echo "  Restart now?"
  echo "y/n"; read ANSWER
  if [ "$ANSWER" = "n" ] ; then
    echo "Exiting now..."
    exit 5
  fi
  shutdown -r -P now
  exit 6
else
  echo "  Please run 'resinstallos' again when you are ready to set up your system."
  read -p "Press the [Enter] key to continue..."
  clear
  exit 0
fi
