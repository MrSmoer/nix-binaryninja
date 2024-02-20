/* This list of dependencies is based on the inofficial binarninja demo distribution
   available at
   https://docs.binary.ninja/guide/troubleshooting.html#nixos
   
   as well as some manual troubleshooting
*/
pkgs:

(with pkgs; [
  dbus
  fontconfig
  python3
  zlib
  freetype
  gcc # is this really necessary?

  libxkbcommon
  libglvnd
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
  # TODO: I didnt really test X11 for binaryninja...
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
