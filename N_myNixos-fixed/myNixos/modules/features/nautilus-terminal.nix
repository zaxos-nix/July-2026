{ ... }: {
  # ════════════════════════════════════════════════════════════════
  # Nautilus right-click "Open Terminal Here" — modern (GTK4) Nautilus
  # dropped its old built-in nautilus-open-terminal integration. The
  # current replacement is the nautilus-open-any-terminal extension,
  # which nixpkgs ships as a first-party NixOS module
  # (programs.nautilus-open-any-terminal) that handles:
  #   - installing nautilus-python + the extension itself
  #   - NAUTILUS_4_EXTENSION_DIR so Nautilus actually finds it
  #     (needed specifically because we're NOT running
  #     services.desktopManager.gnome — see the module's own
  #     `lib.mkIf (!config.services.desktopManager.gnome.enable)`)
  #   - environment.pathsToLink for the extension's data files
  #   - a dconf default setting which terminal to launch
  #
  # Pointed at ghostty since that's what niri.nix already binds to
  # Mod+Return. NOTE: ghostty needs `gtk-single-instance = false` in
  # its own config (~/.config/ghostty/config), or an already-running
  # ghostty instance will ignore the working-directory it's told to
  # open in — you'll get a new tab/window in the wrong directory
  # instead of the folder you right-clicked.
  # ════════════════════════════════════════════════════════════════
  flake.nixosModules.nautilusTerminal = { ... }: {
    programs.nautilus-open-any-terminal = {
      enable = true;
      terminal = "ghostty";
    };
  };
}
