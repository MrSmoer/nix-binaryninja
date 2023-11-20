{
  description = "Nix flake for installation of disassembler Binary ninja.";

  inputs.flake-compat = {
	url = "github:edolstra/flake-compat"
        flake = false;
  };
  outputs = { self, nixpkgs, flake-compat, ... }:
  let 
    pkgs = nixpkgs.legacyPackages.x86_64-linux;
    #targetPks = common.nix;
    runScriptPrefix = {errorOut ? true}: ''
      # Needed for simulink even on wayland systems
      #export QT_QPA_PLATFORM=xcb
      # Search for an imperative declaration of the installation directory of binaryninja
      if [[ -f ~/.config/binaryninja/nix.sh ]]; then
        source ~/.config/binarninja/nix.sh
    '' + pkgs.lib.optionalString errorOut ''else
        echo "nix-binaryninja-error: Did not find ~/.config/binaryninja/nix.sh" >&2
        exit 1
      fi
      if [[ ! -d "$INSTALL_DIR" ]]; then
        echo "nix-binaryninja-error: INSTALL_DIR $INSTALL_DIR isn't a directory" >&2
        exit 2
    '' + ''
      fi
    '';
    desktopItem = pkgs.makeDesktopItem {
    desktopName = "Binary Ninja";
    name = "binaryninja";
    # We use substituteInPlace after we run `install`
    # -desktop is needed, see:
    # https://www.mathworks.com/matlabcentral/answers/20-how-do-i-make-a-desktop-launcher-for-matlab-in-linux#answer_25
    exec = "@out@/bin/binaryninja %u";
    icon = "binary-ninja";
    # Most of the following are copied from octave's desktop launcher
    categories = [
      "Utility"
    ];
    mimeTypes = [
      "text/x-octave"
      "text/x-matlab"
    ];
    keywords = [
      "science"
      "math"
      "matrix"
      "numerical computation"
      "plotting"
    ];
    comment = [
      "Binary Ninja: A Reverse Engineering Platform"
    ];
  };
  # Might be useful for usage of this flake in another flake with devShell +
    # direnv setup. See:
    # https://gitlab.com/doronbehar/nix-matlab/-/merge_requests/1#note_631741222
    shellHooksCommon = (runScriptPrefix {}) + ''
      export C_INCLUDE_PATH=$INSTALL_DIR/extern/include:$C_INCLUDE_PATH
      export CPLUS_INCLUDE_PATH=$INSTALL_DIR/extern/include:$CPLUS_INCLUDE_PATH
      # Rename the variable for others to extend it in their shellHook
      export BINARYNINJA_INSTALL_DIR="$INSTALL_DIR"
      unset INSTALL_DIR
    '';
    # Used in many packages
    metaCommon = with pkgs.lib; {
      homepage = "https://binary.ninja/";
      # This license is not of matlab itself, but for this repository
      license = licenses.mit;
      # Probably best to install this completely imperatively on a system other
      # then NixOS.
      platforms = platforms.linux;
    };

    generatePythonSrc = version: pkgs.requireFile {
      name = "binaryninja-python-src";
      /*
      NOTE: Perhaps for a different matlab installation of perhaps a
      different version of matlab, this hash will be different.
      To check / compare / print the hash created by your installation:

      $ nix-store --query --hash \
          $(nix store add-path $INSTALL_DIR/extern/engines/python --name 'binaryninja-python-src')
      */
      sha256 = {
        "2022a" = "19v09q2y2liinalwxszq3xq70y6mbicbkvzgjvav195pwmz3s36v";
        "2021b" = "19wdzglr8j6966d3s777mckry2kcn99xbfwqyl5j02ir3vidd23h";
      }.${version};
      hashMode = "recursive";
      message = ''
        In order to use the matlab python engine, you have to run these commands:

        > source ~/.config/binaryninja/nix.sh
        > nix store add-path $INSTALL_DIR/extern/engines/python --name 'binaryninja-python-src'

        And hopefully the hash that's in nix-matlab's flake.nix will be the
        same as the one generated from your installation.
      '';
    };
    in {

    packages.x86_64-linux.matlab = pkgs.buildFHSUserEnv {
      name = "binaryninja";
      inherit targetPkgs;
      extraInstallCommands = ''
        install -Dm644 ${desktopItem}/share/applications/binaryninja.desktop $out/share/applications/binaryninja.desktop
        substituteInPlace $out/share/applications/binaryninja.desktop \
          --replace "@out@" ${placeholder "out"}
	#FIX this up, it is built dynamically, idk
        install -Dm644 ${./icons/hicolor/256x256/matlab.png} $out/share/icons/hicolor/256x256/matlab.png
        install -Dm644 ${./icons/hicolor/512x512/matlab.png} $out/share/icons/hicolor/512x512/matlab.png
        install -Dm644 ${./icons/hicolor/64x64/matlab.png} $out/share/icons/hicolor/64x64/matlab.png
      '';
      runScript = pkgs.writeScript "binaryninja-runner" ((runScriptPrefix {}) + ''
        exec $INSTALL_DIR/bin/binaryninja "$@"
      '');
      meta = metaCommon // {
        description = "Binaryninja - the GUI launcher";
      };
    };
    packages.x86_64-linux.binaryninja-shell = pkgs.buildFHSUserEnv {
      name = "binaryninja-shell";
      inherit targetPkgs;
      runScript = pkgs.writeScript "binaryninja-shell-runner" (
        (runScriptPrefix {
          # If the user hasn't setup a ~/.config/binaryninja/nix.sh file yet, don't
          # yell at them that it's missing
          errorOut = false;
        }) + ''
        cat <<EOF
        ============================
        welcome to binaryninja-matlab shell!

        To install binaryninja:
        ${nixpkgs.lib.strings.escape ["`" "'" "\"" "$"] (builtins.readFile ./install.adoc)}

        4. Finish the installation, and exit the shell (with \`exit\`).
        5. Follow the rest of the instructions in the README to make matlab
           executable available anywhere on your system.
        ============================
        EOF
        exec bash
      '');
      meta = metaCommon // {
        description = "A bash shell from which you can install binaryninja or launch binaryninja from CLI";
      };
    };
    # This could have been defined as an overlay for the python3.pkgs attribute
    # set, defined with `packageOverrides`, but this won't bring any benefit
    # because in order to use the matlab engine, one needs to be inside an
    # FHSUser environment anyway.
    packages.x86_64-linux.binaryninja-python-package = pkgs.python3.pkgs.buildPythonPackage rec {
      # No version - can be used with every matlab/binaryninja? version (R2021b or R2021a etc)
      name = "binaryninja-python-package";
      unpackCmd = ''
        cp -r ${src}/ matlab-python-src
        sourceRoot=$PWD/matlab-python-src
      '';
      patches = [
        # Matlab designed this python package to be installed imperatively, and
        # on an impure system - running `python setup.py install` creates an
        # `_arch.txt` file in /usr/local/lib/python3.9/site-packages/matlab (or
        # alike), which tells the `__init__.py` where matlab is installed and
        # where do some .so files reside. This doesn't suit a nix installation,
        # and the best way IMO to work around this is to patch the __init__.py
        # file to use the $MATLAB_INSTALL_DIR to find these shared objects and
        # not read any _arch.txt file.
        ./python-no_arch.txt-file.patch
      ];
      src = generatePythonSrc "2022a";
      meta = metaCommon // {
        homepage = "https://www.mathworks.com/help/matlab/matlab-engine-for-python.html";
        description = "Matlab engine for python - Nix package, slightly patched for a Nix installation";
      };
    };
    packages.x86_64-linux.binaryninja-python-shell = pkgs.buildFHSUserEnv {
      name = "binarynija-python-shell";
      inherit targetPkgs;
      runScript = pkgs.writeScript "binaryninja-python-shell-runner" (shellHooksCommon + ''
        export PYTHONPATH=${self.packages.x86_64-linux.binaryninja-python-package}/${pkgs.python3.sitePackages}
        exec python "$@"
      '');
      meta = metaCommon // {
        homepage = "https://www.mathworks.com/help/matlab/matlab-engine-for-python.html";
        description = "A python shell from which you can use matlab's python engine";
      };
    };
    overlay = final: prev: {
      inherit (self.packages.x86_64-linux)
        binaryninja
        binaryninja-shell
      ;
    };

    inherit shellHooksCommon;
    inherit targetPkgs;
    devShell.x86_64-linux = pkgs.mkShell {
      buildInputs = [
        self.packages.x86_64-linux.binaryninja-shell
      ];
      # From some reason using the attribute matlab-shell directly as the
      # devShell doesn't make it run like that by default.
      shellHook = ''
        exec binaryninja-shell
      '';
    };

    defaultPackage.x86_64-linux = self.packages.x86_64-linux.binaryninja;

  };


}
