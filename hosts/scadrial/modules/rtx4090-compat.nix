{ lib, pkgs, ... }:
{
  boot.kernelPackages = lib.mkForce
    (pkgs.linuxPackagesFor
      (pkgs.linuxKernel.packages.linux_6_1.kernel.override {
        argsOverride = rec {
          version = "6.1.23";
          modDirVersion = version;
          src = pkgs.fetchurl {
            url = "mirror://kernel/linux/kernel/v6.x/linux-${version}.tar.xz";
            sha256 = "sha256-dFg3LodQr+N/0aw+erPCLyxgGPdg+BNAVaA/VKuj6+s=";
          };
        };
      }));

  boot.kernelParams = [
    "module_blacklist=i915"
  ];

  boot.kernelPatches = [
    {
      name = "nouveau.patch";
      # Generated by doing the following:
      # 1. git clone https://gitlab.freedesktop.org/skeggsb/nouveau.git
      # 2. git checkout 01.01-gsp-rm
      # 2. git remote add stable https://git.kernel.org/pub/scm/linux/kernel/git/stable/linux.git
      # 3. git format-patch ea6143a86c67^
      # NOTE: if it gets pushed to again, above commit is "drm/nouveau/disp: move and extend the role of outp acquire/release methods", the first commit in the series
      # 4. git fetch stable --tags
      # 5. git checkout v6.1.3
      # NOTE: or whatever the latest kernel is (in nixpkgs) for the patchset (check the Makefile -- at time of writing, it was 6.1.0-rc2, which is roughly close to 6.1.3)
      # 6. git am *.patch
      # NOTE: you may need to resolve conflicts -- make sure the commit looks roughly the same before and after the rebase
      # 7. git format-patch v6.1.3 --stdout > nouveau.patch
      # NOTE: into one file because `boot.kernelPatches` doesn't like a super long list of patches
      # NOTE: you will be rebuilding the kernel and anything that depends on it
      patch = ./nouveau.patch;
    }
  ];

  hardware.opengl.package = (
    (pkgs.mesa_23_0.overrideAttrs ({ mesonFlags ? [ ], patches ? [ ], ... }: {
      patches = patches ++ [
        (pkgs.fetchpatch {
          name = "nvc0-recognise-ada.patch";
          url = "https://gitlab.freedesktop.org/skeggsb/mesa/-/commit/57081b4692a1d871c8e24c92afdbeb0cfc29d32b.patch";
          sha256 = "sha256-6bX5LBmVe8f9jQTydF0WfFEt8ptYCcf30PaL10A8w0A=";
        })
      ];
    }))
  ).drivers;

  hardware.firmware = [
    (pkgs.stdenv.mkDerivation {
      pname = "nvidia-gsp-firmware";
      version = "525.60.11";
      src = pkgs.fetchurl {
        url = "https://us.download.nvidia.com/XFree86/Linux-x86_64/525.60.11/NVIDIA-Linux-x86_64-525.60.11.run";
        sha256 = "sha256-gW7mwuCBPMw9SnlY9x/EmjfGDv4dUdYUbBznJAOYPV0=";
      };

      dontBuild = true;
      dontFixup = true;
      dontStrip = true;

      unpackPhase = ''
        sh $src --extract-only --target build
        cd build
      '';

      installPhase = ''
        mkdir -p $out/lib/firmware/nvidia/ad102/gsp
        mv firmware/gsp_ad10x.bin $out/lib/firmware/nvidia/ad102/gsp/gsp-5256011.bin
      '';
    })
  ];
}
