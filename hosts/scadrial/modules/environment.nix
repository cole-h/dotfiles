{ config, lib, pkgs, ... }:

{
  environment.enableDebugInfo = true;
  environment.systemPackages = with pkgs;
    [
      age
      agenix
      bc
      binutils
      # borgbackup
      cachix
      # cntr # used for breakpointHook
      # cryptsetup # for borgbackup
      dnsutils
      e2fsprogs
      evince
      ffmpeg
      file
      # filezilla # for switch
      gcc
      gdb
      git
      git-crypt
      gnome3.file-roller
      gnome3.nautilus # GUI file manager
      htop
      imagemagick
      kakoune
      libressl.nc # netcat-openbsd
      lsof
      man-pages
      minisign
      ncdu
      neovim
      nix-index
      nixpkgs-fmt
      nix-prefetch
      nix-prefetch-scripts
      nix-top
      openssl
      par # nice paragraph formatter
      pavucontrol
      pciutils
      posix_man_pages
      psmisc
      rsync
      strace
      usbutils
      wireguard-tools
      xdg-utils
      zathura

      bat # cat but better
      bottom # fancy top
      exa # ls but better
      fd # find files
      hexyl # hex viewer
      # libreoffice # Office but worse
      # openconnect # for school VPN, if needed
      ripgrep # grep but better; [overlays]
      # tmate # "Instant Terminal Sharing"
      tokei # code metrics
    ];

  # For nix-direnv (https://github.com/nix-community/nix-direnv)
  nix.extraOptions = ''
    keep-outputs = true
    keep-derivations = true
  '';

  # TODO: drop after next fish update
  environment.etc."fish/generated_completions".source =
    let
      patchedGenerator = pkgs.stdenv.mkDerivation {
        name = "fish_patched-completion-generator";
        srcs = [
          "${pkgs.fish}/share/fish/tools/create_manpage_completions.py"
          "${pkgs.fish}/share/fish/tools/deroff.py"
        ];
        unpackCmd = "cp $curSrc $(basename $curSrc)";
        sourceRoot = ".";
        patches = [
          (pkgs.writeText "fish_completion-generator.patch" ''
            --- a/create_manpage_completions.py
            +++ b/create_manpage_completions.py
            @@ -867,9 +867,6 @@ def parse_manpage_at_path(manpage_path, output_directory):
                             )
                             return False

            -        # Output the magic word Autogenerated so we can tell if we can overwrite this
            -        built_command_output.insert(0, "# " + CMDNAME +
            -                "\n# Autogenerated from man page " + manpage_path)
                     # built_command_output.insert(2, "# using " + parser.__class__.__name__) # XXX MISATTRIBUTES THE CULPABLE PARSER! Was really using Type2 but reporting TypeDeroffManParser

                     for line in built_command_output:
          '')
        ]; # to prevent collisions of identical completion files
        dontBuild = true;
        installPhase = ''
          mkdir -p $out
          cp * $out/
        '';
        preferLocalBuild = true;
        allowSubstitutes = false;
      };
      generateCompletions = package: pkgs.runCommand
        "${package.name}_fish-completions"
        (
          {
            inherit package;
            preferLocalBuild = true;
            allowSubstitutes = false;
          }
          // lib.optionalAttrs (package ? meta.priority) { meta.priority = package.meta.priority; }
        )
        ''
          mkdir -p $out
          if [ -d $package/share/man ]; then
            find $package/share/man -type f | xargs ${pkgs.python3.interpreter} ${patchedGenerator}/create_manpage_completions.py --directory $out >/dev/null
          fi
        '';
    in
    lib.mkForce (pkgs.buildEnv {
      name = "system_fish-completions";
      ignoreCollisions = true;
      paths = map generateCompletions config.environment.systemPackages;
    });
}
