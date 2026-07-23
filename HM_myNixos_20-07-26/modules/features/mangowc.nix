{ self, inputs, ... }: {
  flake.nixosModules.mangowc = {
    imports = [ inputs.mango.nixosModules.mango ];

    # Registers the "mango" Wayland session so the greeter lists it as a login
    # option, alongside niri. izax's per-user mango config (autostart, DMS
    # spawn, keybinds) lives in modules/home/izax.nix via the mango flake's
    # Home Manager module (inputs.mango.hmModules.mango).
    programs.mango.enable = true;
  };
}
