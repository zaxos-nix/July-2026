{ self, inputs, ... }: {
  flake.nixosModules.browsers = { pkgs, ... }: {
    nixpkgs.overlays = [ inputs.helium.overlays.default ];

    programs.firefox.enable = true;

    environment.systemPackages = with pkgs; [
      brave
      helium # from the overlay above — not yet packaged in nixpkgs proper
    ];
  };
}
