{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    flake-parts.url = "github:hercules-ci/flake-parts";
    import-tree.url = "github:vic/import-tree";
    wrapper-modules.url = "github:BirdeeHub/nix-wrapper-modules";
    elegant-wave-grub-themes.url = "github:vinceliuice/Elegant-grub2-themes";

    # ── Plymouth "Glow" boot theme ──
    # Not in nixpkgs; pulled from adi1090x's community theme pack
    # (pack_2/glow) and packaged in modules/features/plymouth.nix.
    # NOTE: using git+https rather than the github: tarball shorthand —
    # this repo is largeish (many theme dirs with preview GIFs), and the
    # tarball fetcher has been prone to "Truncated tar archive" errors on
    # flaky connections. The git fetcher resumes/retries more gracefully.
    plymouth-themes = {
      url = "git+https://github.com/adi1090x/plymouth-themes.git";
      flake = false;
    };

    # ── Home management ──
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # ── niri (scrollable-tiling Wayland compositor) ──
    # niri-flake ships both a NixOS module and a Home Manager module that stay
    # in sync with each other, which is what lets izo/zax run different
    # per-user niri configs off one system-level `programs.niri.enable`.
    niri = {
      url = "github:sodiboo/niri-flake";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # ── mangowc (dwl-style Wayland compositor) ──
    # Packaged in nixpkgs too, but the flake also ships a Home Manager
    # module (`hmModules.mango`) that nixpkgs doesn't have yet, and a
    # NixOS module that registers the "mango" session entry, and
    # inputs.dms's greeter module (modules/features/greeter.nix) uses this
    # flake's login-screen compositor.
    # NOTE: this project moved from DreamMaoMao/mangowc to mangowm/mango
    # (renamed MangoWC → MangoWM) — make sure you're not pinned to the old,
    # now-stale location.
    mango = {
      url = "github:mangowm/mango";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # ── Dank Material Shell (Quickshell-based desktop shell) ──
    # NOTE: pinned to the `stable` branch, not the default branch. The
    # default branch has had periods where the Nix greeter module broke
    # (e.g. upstream issue #2525 — a commit renamed/restructured the
    # `programs.dank-material-shell.greeter` option and eval failed with
    # "option does not exist"). `stable` is what upstream's own Nix docs
    # recommend tracking for exactly this reason.
    #
    # Also intentionally NOT following the shared `nixpkgs` input here.
    # DMS bundles a Go component (dms-shell) built with buildGoModule; its
    # vendor/module hash is sensitive to the Go toolchain in whatever
    # nixpkgs builds it, and overriding it onto our unstable pin caused a
    # fixed-output hash mismatch during the Go module vendoring step.
    # Letting it use its own locked nixpkgs matches what upstream tests
    # against and avoids that mismatch.
    dms = {
      url = "github:AvengeMedia/DankMaterialShell/stable";
    };

    # ── Helium browser (not yet in nixpkgs) ──
    helium = {
      url = "github:oxcl/nix-flake-helium-browser";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };
  outputs = inputs: inputs.flake-parts.lib.mkFlake {inherit inputs;} (inputs.import-tree ./modules);
}
