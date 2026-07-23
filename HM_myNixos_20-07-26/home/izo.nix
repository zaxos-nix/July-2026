# izo — niri + noctalia
{ pkgs, lib, self, inputs, ... }:
let
  system = pkgs.stdenv.hostPlatform.system;
  noctalia = self.packages.${system}.myNoctalia;
in
{
  imports = [
    ./common.nix
    # NOTE: not importing inputs.niri.homeModules.niri here — niri-flake's
    # NixOS module (modules/features/niri.nix) auto-wires its Home Manager
    # module into every user when home-manager is present. Importing it
    # again here caused a duplicate `programs.niri.finalConfig` declaration.
  ];

  home.username = "izo";
  home.homeDirectory = "/home/izo";

  home.packages = with pkgs; [
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

    spawn-at-startup = [
      { command = [ (lib.getExe noctalia) ]; }
      { command = [ "${pkgs.lxqt.lxqt-policykit}/bin/lxqt-policykit-agent" ]; }
    ];

    binds = {
      "Mod+Return" = { action.spawn = [ (lib.getExe pkgs.ghostty) ]; };
      "Mod+N"      = { action.spawn = [ (lib.getExe pkgs.nautilus) ]; };
      "Mod+B"      = { action.spawn = [ (lib.getExe pkgs.brave) ]; };
      "Mod+T"      = { action.spawn = [ (lib.getExe pkgs.foot) ]; };
      "Mod+M"      = { action.spawn = [ (lib.getExe pkgs.ghostty) "-e" (lib.getExe pkgs.yazi) ]; };

      "Mod+Space".action.spawn-sh = "${lib.getExe noctalia} ipc call launcher toggle";

      "Mod+O"     = { action.toggle-overview = [ ]; };
      "Mod+Slash" = { action.show-hotkey-overlay = [ ]; };

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
