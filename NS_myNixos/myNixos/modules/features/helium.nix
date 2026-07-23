{ inputs, ... }: {
  # Helium isn't in nixpkgs yet, so this pulls in the community
  # flake (oxcl/nix-flake-helium-browser), which ships a proper
  # NixOS module (declarative flags + Chromium-style policies)
  # instead of just a bare package.
  flake.nixosModules.helium = { ... }: {
    imports = [ inputs.helium.nixosModules.default ];

    programs.helium = {
      enable = true;

      # Command-line flags always passed to Helium.
      flags = [
        "--ozone-platform-hint=auto"
      ];

      # Chrome-Enterprise-style policies, written to
      # /etc/chromium/policies/managed/ (Helium is Chromium-based
      # and reads policies from there).
      policies = {
        BrowserSignin = 0;
        SyncDisabled = true;
        PasswordManagerEnabled = true;
      };
    };
  };
}
