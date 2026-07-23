# izo — niri + noctalia
{ pkgs, lib, self, inputs, ... }:
let
  system = pkgs.stdenv.hostPlatform.system;
  noctalia = self.packages.${system}.myNoctalia;
in
{
  imports = [
    ./common.nix
    inputs.niri.homeModules.niri
  ];

  home.username = "izo";
  home.homeDirectory = "/home/izo";

  home.packages = with pkgs; [
    ghostty
    foot
    brave
    nautilus
  ];

  # NOTE: verify this option path (`programs.niri.settings`) against the
  # pinned niri-flake revision — it mirrors the NixOS module's settings.nix,
  # but flake output names do shift between releases.
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

    spawn-at-startup = [
      (lib.getExe noctalia)
      [ "${pkgs.lxqt.lxqt-policykit}/bin/lxqt-policykit-agent" ]
    ];

    binds = {
      "Mod+Return" = { spawn = [ (lib.getExe pkgs.ghostty) ]; };
      "Mod+N"      = { spawn = [ (lib.getExe pkgs.nautilus) ]; };
      "Mod+B"      = { spawn = [ (lib.getExe pkgs.brave) ]; };
      "Mod+T"      = { spawn = [ (lib.getExe pkgs.foot) ]; };
      "Mod+M"      = { spawn = [ (lib.getExe pkgs.ghostty) "-e" (lib.getExe pkgs.yazi) ]; };

      "Mod+Space".spawn-sh = "${lib.getExe noctalia} ipc call launcher toggle";

      "Mod+O"     = { toggle-overview = [ ]; };
      "Mod+Slash" = { show-hotkey-overlay = [ ]; };

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
