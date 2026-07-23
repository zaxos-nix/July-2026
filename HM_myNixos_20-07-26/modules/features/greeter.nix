{ self, inputs, ... }: {
  flake.nixosModules.greeter = { lib, ... }: {
    imports = [ inputs.dms.nixosModules.greeter ];

    services.xserver.enable = lib.mkForce false;

    # dms-greeter runs on greetd (a small Rust login daemon) instead of a
    # full display-manager stack like SDDM, and renders the login screen
    # with Quickshell — the same toolkit zax/izax already run DMS on, so
    # there's no separate Qt/KDE dependency chain just for the login screen.
    # It shows every session registered under /usr/share/wayland-sessions
    # (niri, mango) at login, same as SDDM did — izo/zax/izax all still
    # pick their own session there.
    programs.dank-material-shell.greeter = {
      enable = true;
      compositor.name = "niri";
      # NOTE: copies this user's DMS settings/wallpaper to the greeter's
      # data dir as root before it starts, purely cosmetic for the login
      # screen's look — pick whichever of izo/zax/izax you want it to
      # borrow theming from. Since izo runs noctalia rather than DMS, zax
      # is arguably the more representative choice here.
      configHome = "/home/zax";
    };

    # WORKAROUND: the upstream greeter's prestart script does a plain `cp`
    # of zax's current wallpaper into /var/lib/dms-greeter/wallpaper. If
    # zax's own "current wallpaper" pointer ever resolves to that same
    # path (e.g. leftover from following DMS's upstream *manual sync*
    # docs, which symlink in the *opposite* direction — from
    # ~/.local/state/DankMaterialShell back to the greeter's cache dir —
    # instead of the cp-based sync this NixOS module already does), `cp`
    # refuses with "are the same file" and exits 1, which fails the
    # ExecStartPre and takes down greetd.service entirely (silent hang at
    # boot, no greeter, no error visible without journalctl).
    #
    # Real fix if this recurs: check for and remove any stray manual-sync
    # symlinks under ~zax/.config/DankMaterialShell, ~zax/.local/state,
    # or /var/lib/dms-greeter that point back at each other — this module
    # already handles syncing on its own, manual symlinks conflict with it.
    #
    # This override is a safety net: it tells systemd to treat exit code 1
    # as success for greetd.service's processes, so this specific
    # non-fatal cosmetic failure can no longer take the whole login screen
    # down. Worth removing once bumping the `dms` flake input picks up an
    # upstream fix (they've been hardening this prestart script — see the
    # "skip invalid customThemeFile in preStart" fix in recent releases).
    systemd.services.greetd.serviceConfig.SuccessExitStatus = [ 1 ];
  };
}
