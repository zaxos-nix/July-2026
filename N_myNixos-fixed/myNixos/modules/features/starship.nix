{ ... }: {
  flake.nixosModules.starshipPrompt = { lib, ... }: {
    # programs.starship is a genuine system-wide NixOS module (not Home
    # Manager) — it wires itself into Fish's init for us.
    #
    # Styles below use named ANSI colors ("blue", "green", etc.) rather
    # than fixed hex. Ghostty's terminal palette is now themed live by
    # DMS's dynamic theming (see dms-shell.nix's enableDynamicTheming),
    # so named colors let Starship inherit whatever scheme DMS currently
    # has active instead of asserting a second, competing palette.
    programs.starship = {
      enable = true;
      interactiveOnly = true;

      settings = {
        add_newline = true;
        command_timeout = 1000;
        scan_timeout = 30;

        format = lib.concatStrings [
          "$username"
          "$hostname"
          "$directory"
          "$git_branch"
          "$git_status"
          "$nix_shell"
          "$cmd_duration"
          "$line_break"
          "$character"
        ];

        username = {
          style_user = "bold magenta";
          style_root = "bold red";
          format = "[$user]($style) ";
          show_always = false;
        };

        hostname = {
          ssh_only = true;
          format = "on [$hostname]($style) ";
          style = "bold yellow";
        };

        directory = {
          style = "bold blue";
          truncation_length = 3;
          truncate_to_repo = true;
        };

        git_branch = {
          symbol = " ";
          style = "bold magenta";
          format = "[$symbol$branch]($style) ";
        };

        git_status = {
          style = "bold yellow";
          format = "([$all_status$ahead_behind]($style)) ";
        };

        nix_shell = {
          symbol = " ";
          style = "bold cyan";
          format = "[$symbol$name]($style) ";
        };

        cmd_duration = {
          min_time = 2000;
          style = "bold yellow";
          format = "took [$duration]($style) ";
        };

        character = {
          success_symbol = "[➜](bold green)";
          error_symbol = "[➜](bold red)";
        };
      };
    };
  };
}
