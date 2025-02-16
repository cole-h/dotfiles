{ inputs, config, lib, pkgs, ... }:

{
  imports =
    [
      ./modules
      ../../_common/vin
    ];

  home.homeDirectory = "/home/vin";

  services.syncthing.enable = true;

  # Finally, a cursor theme that displays hands on clickable objects
  home.pointerCursor = {
    package = pkgs.adwaita-icon-theme;
    name = "Adwaita";
    size = 24;
  };

  home = {
    packages = with pkgs;
      [
        firefox-bin
        qimgv # image viewer

        (vscode-with-extensions.override {
          vscodeExtensions = with vscode-extensions; [
            ms-vsliveshare.vsliveshare
            rust-lang.rust-analyzer
            hashicorp.terraform
            golang.go
            eamodio.gitlens
            bbenoist.nix
            stkb.rewrap
            usernamehw.errorlens
            editorconfig.editorconfig
          ];
        })
      ];

    # NOTE: if you log in from a tty, make sure to erase __HM_SESS_VARS_SOURCED,
    # otherwise sessionVariables won't be sourced in new shells
    sessionVariables = {
      SSH_AUTH_SOCK = "${config.home.homeDirectory}/.1password/agent.sock";
      NIXOS_OZONE_WL = "1"; # enable Ozone Wayland for Electron apps
    };

    # This value determines the Home Manager release that your
    # configuration is compatible with. This helps avoid breakage
    # when a new Home Manager release introduces backwards
    # incompatible changes.
    #
    # You can update Home Manager without changing this value. See
    # the Home Manager release notes for a list of state version
    # changes in each release.
    stateVersion = "20.09";
  };
}
