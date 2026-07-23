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
        self.nixosModules.greeter
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
      # boot.supportedFilesystems is set by self.nixosModules.driveAutomount.
      #
      # Plymouth (Glow theme, self.nixosModules.plymouth) is re-enabled as
      # of this rebuild. It was previously pulled after repeatedly hanging
      # at boot with no visible error — that turned out to be greetd.service
      # itself failing (a `cp` self-copy bug in the greeter's prestart
      # script, see modules/features/greeter.nix), not Plymouth. Worth
      # keeping an eye on for a boot or two, but should be fine now.

      # ════════════════════════
      # Networking
      # ════════════════════════
      networking.hostName = "nixos";
      networking.networkmanager.enable = true;
      networking.nameservers = ["1.1.1.1" "8.8.8.8"];
      networking.networkmanager.dns = "default";

      # ════════════════════════
      # Locale
      # ════════════════════════
      time.timeZone = "Africa/Nairobi";
      i18n.defaultLocale = "en_US.UTF-8";

      # ════════════════════════
      # Display / session
      # ════════════════════════
      # services.xserver, the dms-greeter/greetd login screen, niri, and
      # mango are all wired up by the
      # feature modules imported above — this host is Wayland-only, no
      # X11 desktop environment.
      services.xserver.xkb = {
        layout = "us";
        variant = "";
      };
      # security.polkit.enable is already set by self.nixosModules.driveAutomount.

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
          # Password: 1221 (sha-512 crypt hash below, not the plaintext).
          # NOTE: `hashedPassword` is re-applied on every rebuild, so it'll
          # overwrite any password later changed with `passwd`. If you set
          # a real per-user password down the line, switch this to
          # `initialHashedPassword` instead so it only seeds it once.
          hashedPassword = "$6$xyzsaltabc$DGPB34C6edgUYlF8smCRTlwutdhbF3Ioam8WHImj7dJ0CRwCv3PXYkOSowXR/6pxSgJQDBoiDVPM8Zhlzp9WG.";
        };
        zax = {
          isNormalUser = true;
          description = "zax";
          extraGroups = [ "networkmanager" "wheel" "storage" "disk" "shared" ];
          shell = pkgs.fish;
          hashedPassword = "$6$xyzsaltabc$DGPB34C6edgUYlF8smCRTlwutdhbF3Ioam8WHImj7dJ0CRwCv3PXYkOSowXR/6pxSgJQDBoiDVPM8Zhlzp9WG.";
        };
        izax = {
          isNormalUser = true;
          description = "izax";
          extraGroups = [ "networkmanager" "wheel" "storage" "disk" "shared" ];
          shell = pkgs.fish;
          hashedPassword = "$6$xyzsaltabc$DGPB34C6edgUYlF8smCRTlwutdhbF3Ioam8WHImj7dJ0CRwCv3PXYkOSowXR/6pxSgJQDBoiDVPM8Zhlzp9WG.";
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
      # Nautilus "Open in Ghostty" right-click entry
      # ════════════════════════
      # Handles the extension package, NAUTILUS_4_EXTENSION_DIR wiring, and
      # the dconf key that picks Ghostty — nothing else needed here.
      # Ghostty itself needs gtk-single-instance = false (see
      # home/common.nix's programs.ghostty) or a running instance will just
      # eat the --working-directory flag and open a tab where it already is.
      programs.nautilus-open-any-terminal = {
        enable = true;
        terminal = "ghostty";
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
