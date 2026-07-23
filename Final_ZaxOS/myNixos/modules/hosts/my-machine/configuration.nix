{ self, inputs, ... }: {

  flake.nixosModules.myMachineConfiguration = { pkgs, lib, ... }:
    let
      myFirmwareFile = ./hda-jack-retask.fw;
    in
    {
      imports = [
        self.nixosModules.myMachineHardware
        inputs.elegant-wave-grub-themes.nixosModules.default
        inputs.home-manager.nixosModules.home-manager

        # ── Desktop/session features ──
        self.nixosModules.niri
        self.nixosModules.mangowc
        self.nixosModules.sddm
        self.nixosModules.plymouth
        self.nixosModules.driveAutomount
        self.nixosModules.browsers
        self.nixosModules.sharedFolders
      ];

      nix.settings.experimental-features = [ "nix-command" "flakes" ];

      # ════════════════════════
      # Firmware (HDA Jack Retask)
      # ════════════════════════
      hardware.firmware = [
        (pkgs.runCommand "hda-jack-retask-fw" {} ''
          mkdir -p $out/lib/firmware
          cp ${myFirmwareFile} $out/lib/firmware/hda-jack-retask.fw
        '')
      ];
      boot.extraModprobeConfig = ''
        options snd-hda-intel patch=hda-jack-retask.fw
      '';

      # ════════════════════════
      # Bootloader
      # ════════════════════════
      boot.loader.efi.canTouchEfiVariables = true;
      boot.loader.grub = {
        enable = true;
        device = "nodev";
        efiSupport = true;
        useOSProber = true;
      };
      boot.loader.elegant-grub2-theme = {
        enable = true;
        theme = "wave";
        type = "window";
        screen = "1080p";
        side = "right";
        color = "dark";
      };
      # NOTE: boot.plymouth.enable is set by self.nixosModules.plymouth above.
      # boot.supportedFilesystems is set by self.nixosModules.driveAutomount.

      # ════════════════════════
      # Networking
      # ════════════════════════
      networking.hostName = "nixos";
      networking.networkmanager.enable = true;

      # ════════════════════════
      # Locale
      # ════════════════════════
      time.timeZone = "Africa/Nairobi";
      i18n.defaultLocale = "en_US.UTF-8";

      # ════════════════════════
      # Display / session
      # ════════════════════════
      # services.xserver, SDDM, niri, and mango are all wired up by the
      # feature modules imported above — this host is Wayland-only, no
      # X11 desktop environment.
      services.xserver.xkb = {
        layout = "us";
        variant = "";
      };
      security.polkit.enable = true;

      # ════════════════════════
      # Audio
      # ════════════════════════
      services.printing.enable = true;
      services.pulseaudio.enable = false;
      security.rtkit.enable = true;
      services.pipewire = {
        enable = true;
        alsa.enable = true;
        alsa.support32Bit = true;
        pulse.enable = true;
      };

      # ════════════════════════
      # Shell
      # ════════════════════════
      programs.fish.enable = true;

      # ════════════════════════
      # Users
      # ════════════════════════
      users.users = {
        izo = {
          isNormalUser = true;
          description = "izo";
          extraGroups = [ "networkmanager" "wheel" "storage" "disk" "shared" ];
          shell = pkgs.fish;
        };
        zax = {
          isNormalUser = true;
          description = "zax";
          extraGroups = [ "networkmanager" "wheel" "storage" "disk" "shared" ];
          shell = pkgs.fish;
        };
        izax = {
          isNormalUser = true;
          description = "izax";
          extraGroups = [ "networkmanager" "wheel" "storage" "disk" "shared" ];
          shell = pkgs.fish;
        };
      };

      # ════════════════════════
      # Home Manager
      # ════════════════════════
      home-manager = {
        useGlobalPkgs = true;
        useUserPackages = true;
        backupFileExtension = "hm-backup";
        extraSpecialArgs = { inherit self inputs; };
        users = {
          izo = import ../../../home/izo.nix;
          zax = import ../../../home/zax.nix;
          izax = import ../../../home/izax.nix;
        };
      };

      # ════════════════════════
      # Packages
      # ════════════════════════
      nixpkgs.config.allowUnfree = true;

      environment.systemPackages = with pkgs; [
        zed-editor
        kitty
        htop
        mpv
        pcmanfm
        zathura
        fastfetch
        lxqt.lxqt-policykit
      ];
      # Firefox/Brave/Helium are provided by self.nixosModules.browsers.
      # ntfs3g/exfatprogs/udisks2 are provided by self.nixosModules.driveAutomount.

      system.stateVersion = "26.11";
    };
}
