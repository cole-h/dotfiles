{ inputs, lib, ... }:
{
  nix = {
    nixPath = [
      "nixpkgs=${inputs.self}/compat"
      "nixos-config=${inputs.self}/compat/nixos"
    ];

    distributedBuilds = true; # necessary for settings.builders to not be defined in the nix-daemon upstream module
    settings = {
      flake-registry = "/etc/nix/registry.json";
      builders = [ "@/etc/nix/machines" ];
      trusted-public-keys = [
        "scadrial:3FwW08DNiVlNfDWCuBMesZDLISmsgutOLdUt111uvU4="
      ];
    };

    registry = {
      self = {
        to = { type = "path"; path = "${inputs.self}"; }
          // lib.filterAttrs
          (n: _: n == "lastModified" || n == "rev" || n == "revCount" || n == "narHash")
          inputs.self;
      };

      nixpkgs = {
        from = { id = "nixpkgs"; type = "indirect"; };
        to = { type = "path"; path = "${inputs.nixpkgs}"; }
          // lib.filterAttrs
          (n: _: n == "lastModified" || n == "rev" || n == "revCount" || n == "narHash")
          inputs.nixpkgs;
      };
    };
  };
}
