{ self, inputs, ... }: {

  flake.nixosModules.myMachineConfiguration = { pkgs, lib, ... }:
    let
      myFirmwareFile = ./hda-jack-retask.fw;
    in
    {
      imports = [
        self.nixosModules.myMachineHardware
        self.nixosModules.niri
        self.nixosModules.dmsGreeter
        self.nixosModules.fishShell
        self.nixosModules.starshipPrompt
        self.nixosModules.gtkTheming
        self.nixosModules.nautilusTerminal
        inputs.elegant-wave-grub-themes.nixosModules.default
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
      boot.supportedFilesystems = [ "ntfs" ];
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
      # Display / Session
      # ════════════════════════
      # One compositor (Niri), one shell (DMS — spawned by Niri itself
      # as a wrapped package, see dms.nix), one login path (DMS's own
      # greetd-based greeter, see dms-greeter.nix). No X server, no
      # GDM/SDDM, no getty autologin.
      services.udisks2.enable = true;
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
      # Fish itself is configured in modules/features/fish.nix; enabling
      # it here (via that module's import above) also registers it in
      # /etc/shells so it's valid as the login shell set below.

      # ════════════════════════
      # User
      # ════════════════════════
      users.users."izo" = {
        isNormalUser = true;
        description = "izo";
        extraGroups = [ "networkmanager" "wheel" "storage" "disk" ];
        packages = with pkgs; [ ];
        shell = pkgs.fish;
      };

      # ════════════════════════
      # Packages
      # ════════════════════════
      programs.firefox.enable = true;
      nixpkgs.config.allowUnfree = true;

      environment.systemPackages = with pkgs; [
        brave
        zed-editor
        ghostty
        kitty
        git
        htop
        mpv
        imv
        yazi
        neovim
        nautilus
        zathura
        ntfs3g
        fastfetch
      ];

      system.stateVersion = "26.05";
    };
}
