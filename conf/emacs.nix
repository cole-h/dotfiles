{ config, pkgs, ... }:

{
  # Emacs 27+ supports the XDG Base Directory specification, so drop doom into
  # $XDG_CONFIG_HOME/emacs
  xdg.configFile."emacs".source = "${pkgs.doom-emacs}/share/doom-emacs";

  home = {
    packages = with pkgs; [
      doom-emacs
      emacsGit # from emacs-overlay [overlays]
    ];

    sessionVariables = {
      # Separate doom-emacs and its local things so updating doesn't wipe out
      # straight packages and such.
      DOOMLOCALDIR = "${config.xdg.dataHome}/doom-local";

      # Don't want to have to `home-manager switch` every time I change something,
      # so don't add it to the store.
      DOOMDIR = ./doom;
    };
  };
}
