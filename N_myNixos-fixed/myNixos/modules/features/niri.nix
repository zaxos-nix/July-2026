{ self, inputs, ... }: {
  flake.nixosModules.niri = { pkgs, ... }: {
    programs.niri = {
      enable = true;
      package = self.packages.${pkgs.stdenv.hostPlatform.system}.myNiri;
    };
  };

  perSystem = { pkgs, lib, self', ... }: {
    packages.myNiri = inputs.wrapper-modules.wrappers.niri.wrap {
      inherit pkgs;
      v2-settings = true;
      settings = {

        # Fixed: Prevents the hotkey guide from showing up on launch
        hotkey-overlay = {
          skip-at-startup = true;
        };

        # --- INPUTS ---
        input = {
          keyboard.xkb = {
            layout = "us";
          };
          touchpad = {
            # Fixed: Changing to an empty list forces the wrapper to
            # output a bare flag 'tap' without appending 'true'
            tap = [ ];
          };
        };

        # --- OUTPUTS (MONITORS) ---
        outputs."eDP-1" = {
          scale = 1.0;
          transform = "normal";
        };

        # --- LAYOUT AND BEHAVIOR ---
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

          # Fixed: Replaced "enable = false" with Niri's literal 'off' syntax flag.
          border = {
            off = [ ];
          };
        };

        prefer-no-csd = [ ];

        # --- STARTUP ENVIRONMENT ---
        # DMS is a plain wrapped package here (perSystem.packages.myDms —
        # see dms.nix), same role Noctalia used to fill: nothing installs
        # or manages it as a service, niri just spawns it directly. DMS
        # ships its own polkit agent, notification daemon, and idle/lock
        # handling, so no separate lxqt-policykit spawn is needed either.
        spawn-at-startup = [
          [ (lib.getExe self'.packages.myDms) "run" ]
        ];

        # --- KEYBINDINGS ---
        binds = {
          # --- Core Launchers ---
          "Mod+Return" = { spawn = [ (lib.getExe pkgs.ghostty) ]; };
          "Mod+N"      = { spawn = [ (lib.getExe pkgs.nautilus) ]; };
          "Mod+B"      = { spawn = [ (lib.getExe pkgs.brave) ]; };
          #"Mod+T"      = { spawn = [ (lib.getExe pkgs.foot) ]; };
          #"Mod+M"      = { spawn = [ (lib.getExe pkgs.nemo) ]; };

          # DMS's launcher is called "spotlight" in its own IPC vocabulary
          "Mod+Space".spawn-sh = "${lib.getExe self'.packages.myDms} ipc call spotlight toggle";

          # Fixed: Corrected to match the wrapper's action set structure
          "Mod+O"     = { toggle-overview = [ ]; };
          "Mod+Slash" = { show-hotkey-overlay = [ ]; };

          # --- Window & Layout Control ---
          "Mod+Q"       = { close-window = [ ]; };
          "Mod+R"       = { switch-preset-column-width = [ ]; };
          "Mod+F"       = { maximize-column = [ ]; };
          "Mod+Shift+F" = { fullscreen-window = [ ]; };

          # --- Column Navigation ---
          "Mod+Left"  = { focus-column-left = [ ]; };
          "Mod+Right" = { focus-column-right = [ ]; };
          "Mod+Down"  = { focus-window-down = [ ]; };
          "Mod+Up"    = { focus-window-up = [ ]; };

          # --- Moving Columns ---
          "Mod+Ctrl+Left"  = { move-column-left = [ ]; };
          "Mod+Ctrl+Right" = { move-column-right = [ ]; };

          # --- Workspace Quick Navigation ---
          "Mod+1" = { focus-workspace = 1; };
          "Mod+2" = { focus-workspace = 2; };
          "Mod+3" = { focus-workspace = 3; };

          # --- Move Columns to Workspaces ---
          "Mod+Shift+1" = { move-column-to-workspace = 1; };
          "Mod+Shift+2" = { move-column-to-workspace = 2; };
          "Mod+Shift+3" = { move-column-to-workspace = 3; };

          # --- System Controls ---
          "Mod+Shift+E" = { quit = [ ]; };
        };
      };
    };
  };
}
