{ ... }: {
  flake.nixosModules.yazi = { pkgs, ... }: {
    # `programs.yazi` is a real system-wide NixOS module (not just a
    # package): it takes these settings, bakes them into a wrapped
    # `yazi` binary via $YAZI_CONFIG_HOME, and installs that instead
    # of a bare, unconfigured yazi.
    programs.yazi = {
      enable = true;

      settings = {
        yazi = {
          mgr = {
            ratio           = [ 1 3 4 ];
            sort_by         = "natural";
            sort_dir_first  = true;
            show_hidden     = false;
            show_symlink    = true;
            linemode        = "size";
            scrolloff       = 5;
          };

          preview = {
            wrap          = "no";
            tab_size      = 2;
            max_width     = 1920;
            max_height    = 1080;
            image_filter  = "lanczos3";
            image_quality = 90;
          };

          # Route a few common file types to apps already in
          # environment.systemPackages, instead of yazi's generic
          # xdg-open fallback.
          opener = {
            play = [
              { run = ''${pkgs.mpv}/bin/mpv "$@"''; orphan = true; desc = "Play with mpv"; }
            ];
            open-pdf = [
              { run = ''${pkgs.zathura}/bin/zathura "$@"''; orphan = true; desc = "Open with Zathura"; }
            ];
          };

          open = {
            prepend_rules = [
              { mime = "video/*"; use = "play"; }
              { mime = "audio/*"; use = "play"; }
              { mime = "application/pdf"; use = "open-pdf"; }
            ];
          };
        };
      };
    };

    # Fish integration: typing `y` opens yazi, and cd's your shell
    # into whatever directory you were browsing when you quit.
    programs.fish.interactiveShellInit = ''
      function y
          set tmp (mktemp -t "yazi-cwd.XXXXXX")
          yazi $argv --cwd-file="$tmp"
          if set cwd (cat -- "$tmp"); and [ -n "$cwd" ]; and [ "$cwd" != "$PWD" ]
              cd -- "$cwd"
          end
          rm -f -- "$tmp"
      end
    '';
  };
}
