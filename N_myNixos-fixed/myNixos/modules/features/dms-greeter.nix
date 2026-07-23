{ ... }: {
  # ════════════════════════════════════════════════════════════════
  # Login: DMS's own greetd-based greeter, replacing tty1 autologin.
  #
  # services.displayManager.dms-greeter is native to nixpkgs (26.05+),
  # same as programs.dms-shell — it wires up greetd and the greeter
  # session itself, so this needs no extra flake input and no
  # home-manager, matching how everything else in this repo is done.
  #
  # compositor.name = "niri" tells the greeter which compositor to
  # run its own session in. It picks up the system's configured niri
  # (programs.niri.package — the wrapper-modules-wrapped `myNiri`
  # from niri.nix), not a separate copy, so the greeter session and
  # your actual desktop session are the same build.
  #
  # configHome points at izo's home directory so the greeter copies
  # over their DMS theme/wallpaper before it starts, rather than
  # showing a differently-themed greeter than the desktop behind it.
  #
  # NOTE — do NOT add services.displayManager.autoLogin alongside
  # this. As of nixpkgs 26.05 that combination is a known upstream
  # bug: dms-greeter.nix references a services.displayManager.
  # autoLogin.command option that doesn't exist, and the build fails
  # to evaluate outright (https://github.com/NixOS/nixpkgs/issues/473688).
  # That's also just the right call here regardless of the bug — you
  # asked for the greeter, and autologin would skip past it every
  # boot, so autologin.nix has been removed rather than kept
  # alongside this.
  # ════════════════════════════════════════════════════════════════
  flake.nixosModules.dmsGreeter = { ... }: {
    services.displayManager.dms-greeter = {
      enable = true;
      compositor.name = "niri";
      configHome = "/home/izo";
    };
  };
}
