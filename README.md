# Nix FHS environment to run binary ninja
This flake makes running Binaryninja easy. 900% of this are borrowed from a similar [flake for running matlab.](https://gitlab.com/doronbehar/nix-matlab).

Actually it is not really neccessarry to run binaryninja in an FHS, buuut there is some magic going on with its python stuff, and because matlab also has some python stuff i hope this makes it work with the python modules ... I'll see
