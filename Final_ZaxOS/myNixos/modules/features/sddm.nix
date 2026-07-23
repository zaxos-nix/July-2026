{ self, inputs, ... }: {
  flake.nixosModules.sddm = { pkgs, lib, ... }: {
    services.xserver.enable = lib.mkForce false;

    services.displayManager.sddm = {
      enable = true;
      wayland.enable = true;
      # Renders SDDM itself in a Wayland-native Qt6 greeter instead of
      # falling back to Xorg for the login screen.
      package = pkgs.kdePackages.sddm;
    };

    # Wayland-only host: no X desktop manager is enabled here, since izo,
    # zax, and izax all log into niri or mango sessions registered by
    # modules/features/niri.nix and modules/features/mangowc.nix.
    services.displayManager.defaultSession = lib.mkDefault "niri";
  };
}
