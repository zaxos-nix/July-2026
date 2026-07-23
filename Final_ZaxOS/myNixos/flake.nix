{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    flake-parts.url = "github:hercules-ci/flake-parts";
    import-tree.url = "github:vic/import-tree";
    wrapper-modules.url = "github:BirdeeHub/nix-wrapper-modules";
    elegant-wave-grub-themes.url = "github:vinceliuice/Elegant-grub2-themes";

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
    # NixOS module that registers the SDDM/greeter session entry for us.
    # NOTE: this project moved from DreamMaoMao/mangowc to mangowm/mango
    # (renamed MangoWC → MangoWM) — make sure you're not pinned to the old,
    # now-stale location.
    mango = {
      url = "github:mangowm/mango";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # ── Dank Material Shell (Quickshell-based desktop shell) ──
    dms = {
      url = "github:AvengeMedia/DankMaterialShell";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # ── Helium browser (not yet in nixpkgs) ──
    helium = {
      url = "github:oxcl/nix-flake-helium-browser";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };
  outputs = inputs: inputs.flake-parts.lib.mkFlake {inherit inputs;} (inputs.import-tree ./modules);
}
