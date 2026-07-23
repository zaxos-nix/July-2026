{ ... }: {
  flake.nixosModules.fishShell = { ... }: {
    # programs.fish.enable registers fish in /etc/shells and installs
    # NixOS-specific completions and PATH integration. It is already
    # relied on by users.users.izo.shell in configuration.nix.
    programs.fish = {
      enable = true;

      shellAliases = {
        ll  = "ls -lh";
        la  = "ls -lAh";
        gs  = "git status";
        gd  = "git diff";
        gc  = "git commit";
        gp  = "git push";
        nrs = "sudo nixos-rebuild switch --flake .#myMachine";
        nrb = "sudo nixos-rebuild boot --flake .#myMachine";
        nfu = "nix flake update";
        v   = "zeditor";
      };

      shellAbbrs = {
        gco   = "git checkout";
        gaa   = "git add --all";
        gcm   = "git commit -m";
        ".."  = "cd ..";
        "..." = "cd ../..";
      };

      interactiveShellInit = ''
        # --- Custom functions ---
        # programs.fish.functions is a Home Manager option and doesn't
        # exist on the plain NixOS module this repo uses, so functions
        # are defined here as literal fish code instead.
        function mkcd --description 'Create a directory (with parents) and cd into it'
          mkdir -p $argv[1]; and cd $argv[1]
        end

        # --- Colored completions ---
        # Named ANSI colors rather than fixed hex: DMS now owns the live
        # color scheme (wallpaper-derived, via its enableDynamicTheming /
        # matugen pipeline — see dms-shell.nix) and pushes it into
        # Ghostty's 16-color terminal palette at runtime. Naming colors
        # here instead of hardcoding hex means Fish's completions always
        # track whatever theme DMS currently has active, rather than
        # fighting it with a second, competing palette.
        set -g fish_color_normal        normal
        set -g fish_color_command       blue
        set -g fish_color_param         normal
        set -g fish_color_keyword       magenta
        set -g fish_color_quote         green
        set -g fish_color_redirection   cyan
        set -g fish_color_end           yellow
        set -g fish_color_error         red
        set -g fish_color_comment       brblack
        set -g fish_color_autosuggestion brblack
        set -g fish_pager_color_prefix  magenta
        set -g fish_pager_color_completion normal
        set -g fish_pager_color_description brblack

        # --- XDG-compliant environment ---
        set -gx XDG_CONFIG_HOME "$HOME/.config"
        set -gx XDG_DATA_HOME   "$HOME/.local/share"
        set -gx XDG_CACHE_HOME  "$HOME/.cache"
        set -gx XDG_STATE_HOME  "$HOME/.local/state"
        set -gx EDITOR "zeditor"

        # No tty1-autologin-to-niri-session handoff anymore: login is
        # now owned end-to-end by dms-greeter (see dms-greeter.nix),
        # which launches niri-session itself once you authenticate.
        # Fish is purely an interactive shell here, not part of the
        # login path.
      '';
    };
  };
}
