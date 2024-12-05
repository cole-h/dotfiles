{
  # NOTE: Required for a proper setup (e.g. home-manager stuff wasn't added before I added this)
  programs.zsh.enable = true;

  programs.fish.enable = true;
  programs.fish.loginShellInit = ''
    for p in (string split " " $NIX_PROFILES)
      fish_add_path --prepend --move $p/bin
    end
  '';

  # NOTE: Won't work after system updates; will need to re-apply nix-darwin
  # configuration.
  # security.pam.enableSudoTouchIdAuth = true;

  # FIXME: Why is this necessary? home-manager dies otherwise...
  users.users.vin.home = "/Users/vin";

  # # We install Nix using a separate installer so we don't want nix-darwin
  # # to manage it for us. This tells nix-darwin to just use whatever is running.
  # nix.useDaemon = true;

  # We use the auto-allocated-uids Nix feature, so there are no build users to
  # validate (Nix will create them as needed).
  # system.checks.verifyBuildUsers = false;

  system.stateVersion = 5;
}
