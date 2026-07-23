{ self, inputs, ... }: {
  flake.nixosModules.plymouth = { lib, ... }: {
    boot = {
      plymouth = {
        enable = true;
        theme = lib.mkDefault "spinner";
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
      # before SDDM takes over; harmless if unused.
      loader.timeout = lib.mkDefault 2;
    };
  };
}
