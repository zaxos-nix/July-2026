{ self, inputs, ... }: {
  flake.nixosModules.plymouth = { lib, pkgs, ... }:
    let
      # adi1090x/plymouth-themes ships each theme as its own top-level dir
      # per pack rather than a nix-buildable project. The theme is named
      # "glowing" upstream (pack_2/glowing) — and it has to be installed
      # under that same name here too: nixpkgs' own `plymouth` package
      # already bundles a *different*, stock theme literally called "glow",
      # so naming ours "glow" collided with it in buildEnv (two paths
      # providing share/plymouth/themes/glow/...). Using "glowing"
      # throughout avoids the clash entirely.
      plymouth-theme-glowing = pkgs.stdenvNoCC.mkDerivation {
        pname = "plymouth-theme-glowing";
        version = "unstable";
        src = inputs.plymouth-themes;
        dontBuild = true;
        installPhase = ''
          mkdir -p $out/share/plymouth/themes/glowing
          cp -r pack_2/glowing/. $out/share/plymouth/themes/glowing/
        '';
      };
    in
    {
      boot = {
        plymouth = {
          enable = true;
          theme = lib.mkDefault "glowing";
          themePackages = [ plymouth-theme-glowing ];
        };

        # Quiet boot: hides the kernel log spam behind the Plymouth splash.
        consoleLogLevel = lib.mkDefault 0;
        initrd.verbose = false;
        kernelParams = [
          "quiet"
          "splash"
          "boot.shell_on_fail"
          "udev.log_priority=3"
          "rd.udev.log_level=3"
        ];

        # Plymouth needs a bit of extra time on some setups to actually show
        # before the greeter takes over; harmless if unused.
        loader.timeout = lib.mkDefault 2;
      };
    };
}
