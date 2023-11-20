/* This list of dependencies is based on the inofficial binarninja demo distribution
   available at
   https://docs.binary.ninja/guide/troubleshooting.html#nixos
   
   as well as some manual troubleshooting
*/
pkgs:

(with pkgs; [
 # cacert
 # alsa-lib # libasound2
 # atk
 # glib
 # glibc
  dbus
  fontconfig
 # gdk-pixbuf
  #gst-plugins-base
  # gstreamer
 # gtk3
 # nspr
 # nss
 # pam
 # pango
  python3
 # libselinux
 # libsndfile
 # glibcLocales
 # procps
 # unzip
  zlib

  # These packages are needed since 2021b version
 # gnome2.gtk
 # at-spi2-atk
 # at-spi2-core
 # libdrm
 # mesa.drivers
  
  freetype
  gcc
 # gfortran

  # nixos specific
 # udev
 # jre
 # ncurses # Needed for CLI

  # Keyboard input may not work in simulink otherwise
  libxkbcommon
 # xkeyboard_config

  # Needed since 2022a
  libglvnd

  # Needed since 2022b
 # libuuid
 # libxcrypt
   wayland
]) ++ (with pkgs.xorg; [
  #libSM
  libX11
  xcbutilwm
  xcbutilimage
  xcbutilkeysyms
  xcbutilrenderutil
  libxcb
  #libXcomposite
  libXcursor
  #libXdamage
  #libXext
  #libXfixes
  #libXft
  #libXi
  #libXinerama
  #libXrandr
  #libXrender
  #libXt
  #libXtst
  #libXxf86vm
])
