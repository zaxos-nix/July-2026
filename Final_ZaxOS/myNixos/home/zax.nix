# zax — niri + Dank Material Shell (DMS)
{ pkgs, lib, self, inputs, ... }: {
  imports = [
    ./common.nix
    inputs.niri.homeModules.niri
    inputs.dms.homeModules.dank-material-shell
  ];

  home.username = "zax";
  home.homeDirectory = "/home/zax";

  home.packages = with pkgs; [
    ghostty
    foot
    brave
    nautilus
  ];

  # DMS runs itself as a systemd --user service (dms.service) and ships its
  # own launcher/bar/notifications/polkit agent, so unlike izo's noctalia
  # setup it does NOT need a manual `spawn-at-startup` entry.
  programs.dank-material-shell = {
    enable = true;
    # NOTE: verify against the pinned DMS revision — `niri.enableKeybinds`
    # wires DMS's preset niri keybinds (launcher, notifications, settings).
    # Docs warn against combining this with `niri.includes` at the same time.
    niri.enableKeybinds = true;

    # NOTE: verify this key path against the pinned DMS revision — mirrors
    # noctalia's wallpaper.directory/wallpaperChangeMode/randomIntervalSec in
    # modules/features/noctalia.json, pointed at the same shared image pool
    # so izo/zax/izax all rotate through the same wallpapers.
    settings.wallpaper = {
      path = "/home/Shared/Pictures/Wallpapers";
      mode = "random";
      cyclingEnabled = true;
      cyclingInterval = 300; # seconds, matches noctalia's randomIntervalSec
    };
  };

  programs.niri.settings = {
    hotkey-overlay.skip-at-startup = true;

    input = {
      keyboard.xkb.layout = "us";
      touchpad.tap = [ ];
    };

    outputs."eDP-1" = {
      scale = 1.0;
      transform = "normal";
    };

    layout = {
      gaps = 4;
      center-focused-column = "never";
      default-column-width = { proportion = 1.0; };
      preset-column-widths = [
        { proportion = 0.33333; }
        { proportion = 0.5; }
        { proportion = 0.66667; }
      ];
      focus-ring = {
        width = 2;
        active-color = "#7fc8ff";
        inactive-color = "#505050";
      };
      border.off = [ ];
    };

    prefer-no-csd = [ ];

    binds = {
      "Mod+Return" = { spawn = [ (lib.getExe pkgs.ghostty) ]; };
      "Mod+N"      = { spawn = [ (lib.getExe pkgs.nautilus) ]; };
      "Mod+B"      = { spawn = [ (lib.getExe pkgs.brave) ]; };
      "Mod+T"      = { spawn = [ (lib.getExe pkgs.foot) ]; };
      "Mod+M"      = { spawn = [ (lib.getExe pkgs.ghostty) "-e" (lib.getExe pkgs.yazi) ]; };

      "Mod+Q"       = { close-window = [ ]; };
      "Mod+R"       = { switch-preset-column-width = [ ]; };
      "Mod+F"       = { maximize-column = [ ]; };
      "Mod+Shift+F" = { fullscreen-window = [ ]; };

      "Mod+Left"  = { focus-column-left = [ ]; };
      "Mod+Right" = { focus-column-right = [ ]; };
      "Mod+Down"  = { focus-window-down = [ ]; };
      "Mod+Up"    = { focus-window-up = [ ]; };

      "Mod+Ctrl+Left"  = { move-column-left = [ ]; };
      "Mod+Ctrl+Right" = { move-column-right = [ ]; };

      "Mod+1" = { focus-workspace = 1; };
      "Mod+2" = { focus-workspace = 2; };
      "Mod+3" = { focus-workspace = 3; };

      "Mod+Shift+1" = { move-column-to-workspace = 1; };
      "Mod+Shift+2" = { move-column-to-workspace = 2; };
      "Mod+Shift+3" = { move-column-to-workspace = 3; };

      "Mod+Shift+E" = { quit = [ ]; };
    };
  };
}
