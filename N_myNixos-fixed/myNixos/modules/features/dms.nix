{ inputs, ... }: {
  # ════════════════════════════════════════════════════════════════
  # DankMaterialShell (DMS) — desktop shell, replaces Noctalia.
  #
  # No flake.nixosModules.dms here, on purpose — same as Noctalia
  # before it, DMS doesn't need one. It's just a package
  # (self'.packages.myDms) that niri spawns itself via
  # spawn-at-startup (see niri.nix).
  #
  # UNLIKE niri: wrapper-modules has no curated "dms"/"dank-material-
  # shell" preset (confirmed against the live repo — only `niri` and
  # `noctalia-shell` exist under wrapperModules/). So instead of
  # `inputs.wrapper-modules.wrappers.<name>.wrap { settings = {...}; }`
  # (niri's pattern), this uses the library's lower-level generic API
  # for wrapping *any* package, straight from their own docs:
  #
  #   wlib.evalPackage [
  #     { inherit pkgs; }
  #     ({ pkgs, wlib, lib, ... }: {
  #       imports = [ wlib.modules.default ];
  #       package = pkgs.hello;
  #       ...
  #     })
  #   ]
  #
  # REALITY CHECK, stated plainly rather than glossed over: this is
  # NOT the same kind of "wrap" niri.nix does. niri's wrap bakes a
  # full settings tree into an immutable KDL file inside the store —
  # every keybind and layout setting lives in Nix. DMS does not work
  # that way: it reads/writes its own settings.json and matugen
  # output at runtime under ~/.config and ~/.local/state, the same
  # runtime-writable-config problem that made a wrapper-modules
  # Noctalia wrap "a real pain" for its own maintainers
  # (BirdeeHub/nix-wrapper-modules#337). A wrap of DMS can control
  # PATH and env vars around the binary; it cannot declaratively own
  # DMS's actual configuration the way niri.nix owns niri's.
  #
  # So what this wrap actually buys you, concretely: the `myDms`
  # binary on PATH with `matugen` available for dynamic/wallpaper
  # theming — the one thing that needs to be present for DMS to
  # theme anything at all, and isn't bundled into the plain
  # `pkgs.dms-shell` derivation itself. Everything else (system
  # monitoring via dgop, VPN widgets, audio visualizer, calendar,
  # clipboard-paste) is left OFF here to keep this bloat-free — add
  # to `runtimePkgs` below if you want one of those widgets:
  #   dgop      -> system monitoring widgets
  #   glib      -> VPN widgets (NetworkManager itself is already on
  #                via networking.networkmanager.enable regardless)
  #   cava      -> audio wavelength visualizer
  #   khal      -> calendar widgets
  #   wtype     -> Shift+Return paste from clipboard history
  #
  # OPEN ITEM, genuinely unverified (no `nix` binary in this sandbox
  # to build-check against): the native `programs.dms-shell` NixOS
  # module additionally sets `services.power-profiles-daemon.enable`,
  # `services.accounts-daemon.enable`, `hardware.i2c.enable`, and
  # `hardware.graphics.enable` as mkDefault true, because certain DMS
  # widgets depend on them. Bypassing that module (as this file does,
  # to keep DMS as "just a wrapped package" like Noctalia was) means
  # none of that happens automatically. Most of these are already on
  # by default on real hardware, but confirm rather than assume if a
  # widget (battery/power profile toggle, i2c-backed brightness) is
  # missing after boot.
  # ════════════════════════════════════════════════════════════════
  perSystem = { pkgs, ... }: {
    packages.myDms = inputs.wrapper-modules.lib.evalPackage [
      { inherit pkgs; }
      ({ pkgs, wlib, ... }: {
        imports = [ wlib.modules.default ];
        package = pkgs.dms-shell;
        # quickshell is NOT wired onto PATH by pkgs.dms-shell's own
        # wrapProgram call (confirmed against its actual postInstall —
        # it only prefixes NIXPKGS_QT6_QML_IMPORT_PATH / QT_PLUGIN_PATH).
        # `dms run` shells out to a `quickshell` binary it expects to
        # find on PATH at runtime, so without this, the backend starts,
        # fails to exec quickshell, and exits — with nothing visible in
        # niri's own logs. matugen has the same "external runtime dep,
        # not bundled" status, for dynamic/wallpaper theming.
        runtimePkgs = [ pkgs.matugen pkgs.quickshell ];
      })
    ];
  };
}
