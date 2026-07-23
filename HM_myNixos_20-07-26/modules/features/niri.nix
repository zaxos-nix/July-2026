{ self, inputs, ... }: {
  flake.nixosModules.niri = { pkgs, ... }: {
    imports = [ inputs.niri.nixosModules.niri ];

    # System-wide switch: this just makes a "niri" session available at the
    # login screen and wires up XDG portals / polkit / gnome-keyring.
    # Per-user behaviour (keybinds, autostart, which shell to spawn) is
    # configured separately for each user under modules/home/*.nix via
    # niri-flake's matching Home Manager module.
    programs.niri = {
      enable = true;
      package = pkgs.niri;
    };
  };
}
