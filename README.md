# Nix FHS environment to run binary ninja
_THIS IS WORK IN PROGRESS AND DEFINITELY NOT DONE_ (the main Branch should be at least running tho) 

This flake makes running Binaryninja on nixos (or in a nix environment) easy. 900% of this are borrowed from a similar [flake for running matlab.](https://gitlab.com/doronbehar/nix-matlab).

Actually it is not really neccessarry to run binaryninja in an FHS, buuut there is some magic going on with its python stuff, and because matlab also has some python stuff i hope this makes it work with the python modules ... I'll figure

You can launch a shell using for launching binary-ninja with 
```
nix run github:mrsmoer/nix-binaryninja#binaryninja-shell
```
for further reference please look in the repo for running matlab on nix by doronbehar for now.
There you can also find how to run it without flakes enabled.

It should work on wayland as well. Did for me on gnome ¯\\\_(ツ)_/¯

Pull requests are warmly welcomed always :)
