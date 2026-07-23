# zax — niri + Dank Material Shell (DMS)
{ pkgs, lib, self, inputs, ... }: {
  imports = [
    ./common.nix
    # NOTE: not importing inputs.niri.homeModules.niri here — see the
    # matching comment in home/izo.nix.
    inputs.dms.homeModules.dank-material-shell
    inputs.dms.homeModules.niri # ← required for the `programs.dank-material-shell.niri.*` options below
  ];

  home.username = "zax";
  home.homeDirectory = "/home/zax";

  home.packages = with pkgs; [
    foot
    brave
    nautilus
  ];

  # DMS runs itself as a systemd --user service (dms.service) and ships its
  # own launcher/bar/notifications/polkit agent, so unlike izo's noctalia
  # setup it does NOT need a manual `spawn-at-startup` entry.
  programs.dank-material-shell = {
    enable = true;
    # `niri.includes` (auto-generates the dms/*.kdl config fragments, incl.
    # keybinds) is enabled by default once inputs.dms.homeModules.niri is
    # imported above — deliberately NOT setting niri.enableKeybinds here,
    # since DMS's own docs warn against combining the two.

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
      touchpad.tap = true;
    };

    outputs."eDP-1" = {
      scale = 1.0;
      transform = { rotation = 0; flipped = false; };
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
        active.color = "#7fc8ff";
        inactive.color = "#505050";
      };
      border.enable = false;
    };

    prefer-no-csd = true;

    binds = {
      "Mod+Return" = { action.spawn = [ (lib.getExe pkgs.ghostty) ]; };
      "Mod+N"      = { action.spawn = [ (lib.getExe pkgs.nautilus) ]; };
      "Mod+B"      = { action.spawn = [ (lib.getExe pkgs.brave) ]; };
      "Mod+T"      = { action.spawn = [ (lib.getExe pkgs.foot) ]; };
      "Mod+M"      = { action.spawn = [ (lib.getExe pkgs.ghostty) "-e" (lib.getExe pkgs.yazi) ]; };

      "Mod+Q"       = { action.close-window = [ ]; };
      "Mod+R"       = { action.switch-preset-column-width = [ ]; };
      "Mod+F"       = { action.maximize-column = [ ]; };
      "Mod+Shift+F" = { action.fullscreen-window = [ ]; };

      "Mod+Left"  = { action.focus-column-left = [ ]; };
      "Mod+Right" = { action.focus-column-right = [ ]; };
      "Mod+Down"  = { action.focus-window-down = [ ]; };
      "Mod+Up"    = { action.focus-window-up = [ ]; };

      "Mod+Ctrl+Left"  = { action.move-column-left = [ ]; };
      "Mod+Ctrl+Right" = { action.move-column-right = [ ]; };

      "Mod+1" = { action.focus-workspace = [ 1 ]; };
      "Mod+2" = { action.focus-workspace = [ 2 ]; };
      "Mod+3" = { action.focus-workspace = [ 3 ]; };

      "Mod+Shift+1" = { action.move-column-to-workspace = [ 1 ]; };
      "Mod+Shift+2" = { action.move-column-to-workspace = [ 2 ]; };
      "Mod+Shift+3" = { action.move-column-to-workspace = [ 3 ]; };

      "Mod+Shift+E" = { action.quit = [ ]; };
    };
  };
}
