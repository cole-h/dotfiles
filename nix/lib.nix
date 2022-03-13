{ inputs
}:
rec {
  allSystems = [ "x86_64-linux" "aarch64-linux" ];

  nameValuePair = name: value: { inherit name value; };
  genAttrs = names: f: builtins.listToAttrs (map (n: nameValuePair n (f n)) names);

  pkgsFor =
    { inputs
    , nixpkgs
    , system
    }:
    import nixpkgs {
      inherit system;

      config = {
        # allowAliases = false;
        allowUnfree = true;
        android_sdk.accept_license = true;
      };

      overlays = [
        (import ./overlay.nix)
        (final: prev: {
          agenix = inputs.agenix-cli.defaultPackage.${system};
          mullvad = inputs.mullvad.legacyPackages.${final.system}.mullvad;

          kakoune-unwrapped = prev.kakoune-unwrapped.overrideAttrs ({ ... }: {
            version = inputs.kak.shortRev;
            src = inputs.kak;
          });
        })
      ];
    };

  forAllSystems = f: genAttrs allSystems
    (system: f {
      inherit system;
      pkgs = pkgsFor {
        inherit inputs system;
        inherit (inputs) nixpkgs;
      };
    });

  specialArgs = {
    inherit inputs;

    my = import ../my.nix {
      inherit (inputs.nixpkgs) lib;
    };
  };

  mkSystem =
    { system
    , pkgs
    , modules
    }:
    inputs.nixpkgs.lib.nixosSystem {
      inherit system modules specialArgs pkgs;
    };
}
